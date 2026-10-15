import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_model.dart';
import '../models/cart_model.dart';
import '../models/checkout_item_input_model.dart';
import '../models/order_model.dart';
import '../models/payment_session_model.dart';
import '../models/voucher_model.dart';
import '../repositories/address_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/voucher_repository.dart';
import '../services/cart_service.dart';

const Object _unset = Object();

class CheckoutViewModel extends Notifier<CheckoutState> {
  CheckoutViewModel({
    CartRepository? cartRepository,
    AddressRepository? addressRepository,
    VoucherRepository? voucherRepository,
    OrderRepository? orderRepository,
    PaymentRepository? paymentRepository,
  }) : _cartRepository = cartRepository ?? CartRepository(CartService()),
       _addressRepository = addressRepository ?? AddressRepository(),
       _voucherRepository = voucherRepository ?? VoucherRepository(),
       _orderRepository = orderRepository ?? OrderRepository(),
       _paymentRepository = paymentRepository ?? PaymentRepository();

  final CartRepository _cartRepository;
  final AddressRepository _addressRepository;
  final VoucherRepository _voucherRepository;
  final OrderRepository _orderRepository;
  final PaymentRepository _paymentRepository;

  Future<void>? _loadOperation;
  String? _pendingIdempotencyKey;
  String? _pendingRequestFingerprint;
  int _voucherValidationVersion = 0;

  @override
  CheckoutState build() => CheckoutState();

  /// Loads cart and addresses concurrently. Concurrent calls share one request.
  Future<void> loadCheckout({CartModel? initialCart}) {
    if (state.isSubmitting) return Future<void>.value();
    final runningOperation = _loadOperation;
    if (runningOperation != null) return runningOperation;

    final operation = _loadCheckout(initialCart: initialCart);
    _loadOperation = operation;
    return operation.whenComplete(() {
      if (identical(_loadOperation, operation)) _loadOperation = null;
    });
  }

  Future<void> _loadCheckout({CartModel? initialCart}) async {
    state = state.copyWith(
      isLoading: true,
      loadErrorMessage: null,
      addressErrorMessage: null,
    );

    final cartRequest = initialCart == null
        ? _cartRepository.getCart()
        : Future<CartModel>.value(initialCart);
    final results = await Future.wait<_LoadResult>([
      _capture(cartRequest),
      _capture(_addressRepository.getAddresses()),
    ]);
    final cartResult = results[0];
    final addressResult = results[1];

    final oldItemsFingerprint = _itemsFingerprint(state.cartItems);
    final newItems = cartResult.errorMessage == null
        ? (cartResult.value as CartModel).items
        : state.cartItems;
    final itemsChanged =
        oldItemsFingerprint != _itemsFingerprint(newItems) &&
        cartResult.errorMessage == null;

    List<AddressModel> addresses = state.addresses;
    AddressModel? selectedAddress = state.selectedAddress;
    if (addressResult.errorMessage == null) {
      addresses = addressResult.value as List<AddressModel>;
      selectedAddress = _selectCurrentOrDefaultAddress(
        addresses,
        state.selectedAddress?.id,
      );
    }

    if (itemsChanged) _voucherValidationVersion++;

    state = state.copyWith(
      isLoading: false,
      cartItems: newItems,
      addresses: addresses,
      selectedAddress: selectedAddress,
      validatedVoucher: itemsChanged ? null : _unset,
      isValidatingVoucher: itemsChanged ? false : state.isValidatingVoucher,
      loadErrorMessage: cartResult.errorMessage,
      addressErrorMessage: addressResult.errorMessage,
      voucherErrorMessage: itemsChanged && state.voucherCode.trim().isNotEmpty
          ? 'Giỏ hàng đã thay đổi. Vui lòng kiểm tra lại voucher.'
          : _unset,
    );
  }

  Future<_LoadResult> _capture(Future<Object?> future) async {
    try {
      return _LoadResult(value: await future);
    } catch (error) {
      return _LoadResult(errorMessage: _message(error));
    }
  }

  AddressModel? _selectCurrentOrDefaultAddress(
    List<AddressModel> addresses,
    String? currentAddressId,
  ) {
    for (final address in addresses) {
      if (address.id == currentAddressId) return address;
    }
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return null;
  }

  void selectAddress(String addressId) {
    if (state.isSubmitting || state.createdOrder != null) return;

    AddressModel? selectedAddress;
    for (final address in state.addresses) {
      if (address.id == addressId) {
        selectedAddress = address;
        break;
      }
    }
    if (selectedAddress == null) {
      state = state.copyWith(
        addressErrorMessage: 'Không tìm thấy địa chỉ đã chọn.',
      );
      return;
    }

    state = state.copyWith(
      selectedAddress: selectedAddress,
      addressErrorMessage: null,
      orderErrorMessage: null,
    );
  }

  void setPaymentMethod(OrderPaymentMethod paymentMethod) {
    if (state.isSubmitting || state.createdOrder != null) return;
    state = state.copyWith(
      paymentMethod: paymentMethod,
      orderErrorMessage: null,
      paymentErrorMessage: null,
      paymentSession: null,
    );
  }

  void updateVoucherCode(String code) {
    if (state.isSubmitting || state.createdOrder != null) return;
    if (code == state.voucherCode) return;

    _voucherValidationVersion++;
    state = state.copyWith(
      voucherCode: code,
      validatedVoucher: null,
      isValidatingVoucher: false,
      voucherErrorMessage: null,
      orderErrorMessage: null,
    );
  }

  Future<VoucherValidationModel?> validateVoucher() async {
    if (state.isValidatingVoucher ||
        state.isSubmitting ||
        state.createdOrder != null) {
      return null;
    }

    final code = state.voucherCode.trim();
    if (code.isEmpty) {
      state = state.copyWith(
        validatedVoucher: null,
        voucherErrorMessage: 'Vui lòng nhập mã voucher.',
      );
      return null;
    }
    if (state.cartItems.isEmpty) {
      state = state.copyWith(
        validatedVoucher: null,
        voucherErrorMessage: 'Giỏ hàng đang trống.',
      );
      return null;
    }
    if (state.loadErrorMessage != null) {
      state = state.copyWith(
        validatedVoucher: null,
        voucherErrorMessage: 'Không thể tải giỏ hàng để kiểm tra voucher.',
      );
      return null;
    }

    final validationVersion = ++_voucherValidationVersion;
    final itemsFingerprint = _itemsFingerprint(state.cartItems);
    state = state.copyWith(
      isValidatingVoucher: true,
      validatedVoucher: null,
      voucherErrorMessage: null,
    );

    try {
      final result = await _voucherRepository.validateVoucher(
        VoucherValidationRequest(code: code, items: state.checkoutItems),
      );

      if (validationVersion != _voucherValidationVersion) return null;
      if (state.voucherCode.trim() != code ||
          _itemsFingerprint(state.cartItems) != itemsFingerprint) {
        state = state.copyWith(
          isValidatingVoucher: false,
          validatedVoucher: null,
          voucherErrorMessage: 'Dữ liệu giỏ hàng hoặc voucher đã thay đổi.',
        );
        return null;
      }

      state = state.copyWith(
        isValidatingVoucher: false,
        validatedVoucher: result,
        voucherErrorMessage: null,
      );
      return result;
    } catch (error) {
      if (validationVersion != _voucherValidationVersion) return null;
      state = state.copyWith(
        isValidatingVoucher: false,
        validatedVoucher: null,
        voucherErrorMessage: _message(
          error,
          fallback: 'Không thể xác thực voucher. Vui lòng thử lại.',
        ),
      );
      return null;
    }
  }

  Future<OrderModel?> submitOrder() async {
    if (state.isSubmitting) return state.createdOrder;

    final existingOrder = state.createdOrder;
    if (existingOrder != null) {
      if (existingOrder.paymentMethod == OrderPaymentMethod.vnpay.name &&
          state.paymentSession == null) {
        await retryVnpayPayment();
      }
      return existingOrder;
    }

    if (state.loadErrorMessage != null) {
      state = state.copyWith(
        orderErrorMessage: 'Không thể đặt hàng khi chưa tải được giỏ hàng.',
      );
      return null;
    }
    if (state.addressErrorMessage != null) {
      state = state.copyWith(
        orderErrorMessage: 'Không thể đặt hàng khi chưa tải được địa chỉ.',
      );
      return null;
    }
    if (state.cartItems.isEmpty) {
      state = state.copyWith(orderErrorMessage: 'Giỏ hàng đang trống.');
      return null;
    }
    final selectedAddress = state.selectedAddress;
    if (selectedAddress == null) {
      state = state.copyWith(
        orderErrorMessage: 'Vui lòng chọn địa chỉ giao hàng.',
      );
      return null;
    }
    if (!OrderPaymentMethod.values.contains(state.paymentMethod)) {
      state = state.copyWith(
        orderErrorMessage: 'Phương thức thanh toán không hợp lệ.',
      );
      return null;
    }

    final enteredVoucherCode = state.voucherCode.trim();
    final validatedVoucher = state.validatedVoucher;
    if (enteredVoucherCode.isNotEmpty &&
        (validatedVoucher == null ||
            validatedVoucher.voucher.code.trim().toUpperCase() !=
                enteredVoucherCode.toUpperCase())) {
      state = state.copyWith(
        orderErrorMessage: 'Vui lòng xác thực voucher trước khi đặt hàng.',
      );
      return null;
    }

    final request = CreateOrderRequest(
      items: state.checkoutItems,
      addressId: selectedAddress.id,
      voucherCode: validatedVoucher?.voucher.code,
      paymentMethod: state.paymentMethod,
    );
    final requestFingerprint = jsonEncode(request.toJson());
    if (_pendingIdempotencyKey == null ||
        _pendingRequestFingerprint != requestFingerprint) {
      _pendingIdempotencyKey = _orderRepository.createIdempotencyKey();
      _pendingRequestFingerprint = requestFingerprint;
    }
    final idempotencyKey = _pendingIdempotencyKey!;

    state = state.copyWith(
      isSubmitting: true,
      orderErrorMessage: null,
      paymentErrorMessage: null,
    );

    late final OrderModel order;
    try {
      order = await _orderRepository.createOrder(
        request: request,
        idempotencyKey: idempotencyKey,
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        orderErrorMessage: _message(
          error,
          fallback: 'Không thể tạo đơn hàng. Vui lòng thử lại.',
        ),
      );
      return null;
    }

    // The order now exists; retries must retry payment creation, not Order POST.
    _pendingIdempotencyKey = null;
    _pendingRequestFingerprint = null;
    state = state.copyWith(createdOrder: order, orderErrorMessage: null);

    if (order.paymentMethod == OrderPaymentMethod.vnpay.name) {
      await _createPaymentSession(order);
    }

    state = state.copyWith(isSubmitting: false);
    return order;
  }

  Future<PaymentSessionModel?> retryVnpayPayment() async {
    if (state.isSubmitting || state.isCreatingPaymentSession) return null;
    final order = state.createdOrder;
    if (order == null || order.paymentMethod != OrderPaymentMethod.vnpay.name) {
      state = state.copyWith(
        paymentErrorMessage: 'Không có đơn VNPAY đang chờ thanh toán.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, paymentErrorMessage: null);
    final session = await _createPaymentSession(order);
    state = state.copyWith(isSubmitting: false);
    return session;
  }

  Future<PaymentSessionModel?> _createPaymentSession(OrderModel order) async {
    state = state.copyWith(
      isCreatingPaymentSession: true,
      paymentSession: null,
      paymentErrorMessage: null,
    );
    try {
      final session = await _paymentRepository.createVnpayPayment(order.id);
      state = state.copyWith(
        isCreatingPaymentSession: false,
        paymentSession: session,
        paymentErrorMessage: null,
      );
      return session;
    } catch (error) {
      state = state.copyWith(
        isCreatingPaymentSession: false,
        paymentSession: null,
        paymentErrorMessage: _message(
          error,
          fallback: 'Đơn hàng đã tạo nhưng chưa thể khởi tạo thanh toán.',
        ),
      );
      return null;
    }
  }

  void clearErrors() {
    state = state.copyWith(
      loadErrorMessage: null,
      addressErrorMessage: null,
      voucherErrorMessage: null,
      orderErrorMessage: null,
      paymentErrorMessage: null,
    );
  }

  String _itemsFingerprint(List<CartItemModel> items) => jsonEncode(
    items
        .map((item) => [item.variantId, item.quantity])
        .toList(growable: false),
  );

  String _message(Object error, {String fallback = 'Đã xảy ra lỗi.'}) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      final cleanMessage = message.substring('Exception: '.length).trim();
      return cleanMessage.isEmpty ? fallback : cleanMessage;
    }
    if (message.startsWith('ArgumentError: ')) {
      return fallback;
    }
    return message.trim().isEmpty ? fallback : message;
  }
}

class CheckoutState {
  CheckoutState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isValidatingVoucher = false,
    this.isCreatingPaymentSession = false,
    List<CartItemModel> cartItems = const [],
    List<AddressModel> addresses = const [],
    this.selectedAddress,
    this.voucherCode = '',
    this.validatedVoucher,
    this.paymentMethod = OrderPaymentMethod.cod,
    this.createdOrder,
    this.paymentSession,
    this.loadErrorMessage,
    this.addressErrorMessage,
    this.voucherErrorMessage,
    this.orderErrorMessage,
    this.paymentErrorMessage,
  }) : cartItems = List.unmodifiable(cartItems),
       addresses = List.unmodifiable(addresses);

  final bool isLoading;
  final bool isSubmitting;
  final bool isValidatingVoucher;
  final bool isCreatingPaymentSession;
  final List<CartItemModel> cartItems;
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final String voucherCode;
  final VoucherValidationModel? validatedVoucher;
  final OrderPaymentMethod paymentMethod;
  final OrderModel? createdOrder;
  final PaymentSessionModel? paymentSession;
  final String? loadErrorMessage;
  final String? addressErrorMessage;
  final String? voucherErrorMessage;
  final String? orderErrorMessage;
  final String? paymentErrorMessage;

  List<CheckoutItemInputModel> get checkoutItems => List.unmodifiable(
    cartItems.map(
      (item) => CheckoutItemInputModel(
        variantId: item.variantId,
        quantity: item.quantity,
      ),
    ),
  );

  bool get isEmpty => cartItems.isEmpty;
  double? get subtotal => createdOrder?.subtotal;
  double? get shippingFee => createdOrder?.shippingFee;
  double? get tax => createdOrder?.tax;
  double? get discount => createdOrder?.discount ?? validatedVoucher?.discount;
  double? get total => createdOrder?.total;

  String? get errorMessage =>
      loadErrorMessage ??
      addressErrorMessage ??
      voucherErrorMessage ??
      orderErrorMessage ??
      paymentErrorMessage;

  CheckoutState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isValidatingVoucher,
    bool? isCreatingPaymentSession,
    List<CartItemModel>? cartItems,
    List<AddressModel>? addresses,
    Object? selectedAddress = _unset,
    String? voucherCode,
    Object? validatedVoucher = _unset,
    OrderPaymentMethod? paymentMethod,
    Object? createdOrder = _unset,
    Object? paymentSession = _unset,
    Object? loadErrorMessage = _unset,
    Object? addressErrorMessage = _unset,
    Object? voucherErrorMessage = _unset,
    Object? orderErrorMessage = _unset,
    Object? paymentErrorMessage = _unset,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isValidatingVoucher: isValidatingVoucher ?? this.isValidatingVoucher,
      isCreatingPaymentSession:
          isCreatingPaymentSession ?? this.isCreatingPaymentSession,
      cartItems: cartItems ?? this.cartItems,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress == _unset
          ? this.selectedAddress
          : selectedAddress as AddressModel?,
      voucherCode: voucherCode ?? this.voucherCode,
      validatedVoucher: validatedVoucher == _unset
          ? this.validatedVoucher
          : validatedVoucher as VoucherValidationModel?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdOrder: createdOrder == _unset
          ? this.createdOrder
          : createdOrder as OrderModel?,
      paymentSession: paymentSession == _unset
          ? this.paymentSession
          : paymentSession as PaymentSessionModel?,
      loadErrorMessage: loadErrorMessage == _unset
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      addressErrorMessage: addressErrorMessage == _unset
          ? this.addressErrorMessage
          : addressErrorMessage as String?,
      voucherErrorMessage: voucherErrorMessage == _unset
          ? this.voucherErrorMessage
          : voucherErrorMessage as String?,
      orderErrorMessage: orderErrorMessage == _unset
          ? this.orderErrorMessage
          : orderErrorMessage as String?,
      paymentErrorMessage: paymentErrorMessage == _unset
          ? this.paymentErrorMessage
          : paymentErrorMessage as String?,
    );
  }
}

class _LoadResult {
  const _LoadResult({this.value, this.errorMessage});

  final Object? value;
  final String? errorMessage;
}
