import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/repositories/cart_repository.dart';
import 'package:shoe_store/services/cart_service.dart';

import '../models/cart_model.dart';

class CartViewModel extends Notifier<CartState> {
  late final CartRepository _cartRepository;

  @override
  CartState build() {
    final cartService = CartService();

    _cartRepository = CartRepository(cartService);

    return const CartState();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final cart = await _cartRepository.getCart();
      state = state.copyWith(isLoading: false, cart: cart);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addToCart({
    required String productId,
    required String variantId,
    required int quantity,
  }) async {
    state = state.copyWith(isAdding: true, errorMessage: null);

    try {
      final cart = await _cartRepository.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );

      state = state.copyWith(cart: cart, isAdding: false);
    } catch (e) {
      state = state.copyWith(isAdding: false, errorMessage: e.toString());
    }
  }

  Future<void> updateCartItem({
    required String variantId,
    required int quantity,
  }) async {
    state = state.copyWith(
      updatingVariantIds: {...state.updatingVariantIds, variantId},
      errorMessage: null,
    );

    try {
      final cart = await _cartRepository.updateCartItem(
        variantId: variantId,
        quantity: quantity,
      );

      state = state.copyWith(
        cart: cart,
        updatingVariantIds: {...state.updatingVariantIds}..remove(variantId),
      );
    } catch (e) {
      state = state.copyWith(
        updatingVariantIds: {...state.updatingVariantIds}..remove(variantId),
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> removeFromCart({required String variantId}) async {
    state = state.copyWith(isRemoving: true, errorMessage: null);

    try {
      final cart = await _cartRepository.removeFromCart(variantId: variantId);

      state = state.copyWith(cart: cart, isRemoving: false);
    } catch (e) {
      state = state.copyWith(isRemoving: false, errorMessage: e.toString());
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isClearing: true, errorMessage: null);

    try {
      final cart = await _cartRepository.clearCart();

      state = state.copyWith(cart: cart, isClearing: false);
    } catch (e) {
      state = state.copyWith(isClearing: false, errorMessage: e.toString());
    }
  }
}

class CartState {
  final CartModel? cart;

  final bool isLoading;
  final bool isAdding;
  final Set<String> updatingVariantIds;
  final bool isRemoving;
  final bool isClearing;

  final String? errorMessage;

  static const _unset = Object();

  const CartState({
    this.cart,
    this.isLoading = false,
    this.isAdding = false,
    this.updatingVariantIds = const {},
    this.isRemoving = false,
    this.isClearing = false,
    this.errorMessage,
  });

  // ITEMS
  List<CartItemModel> get items {
    return cart?.items ?? [];
  }

  // CART INFO
  double get subtotal {
    return cart?.subtotal ?? 0;
  }

  int get totalQuantity {
    return cart?.totalQuantity ?? 0;
  }

  int get itemCount {
    return cart?.itemCount ?? 0;
  }

  bool get isEmpty {
    return items.isEmpty;
  }

  bool get isUpdating => updatingVariantIds.isNotEmpty;

  // COPY WITH
  CartState copyWith({
    CartModel? cart,
    bool? isLoading,
    bool? isAdding,
    Set<String>? updatingVariantIds,
    bool? isRemoving,
    bool? isClearing,
    Object? errorMessage = _unset,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      updatingVariantIds: updatingVariantIds ?? this.updatingVariantIds,
      isRemoving: isRemoving ?? this.isRemoving,
      isClearing: isClearing ?? this.isClearing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
