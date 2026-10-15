import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/utils/price_formatter.dart';
import '../../models/order_model.dart';
import '../../viewmodels/cart_provider.dart';
import '../../viewmodels/checkout_provider.dart';
import '../../viewmodels/checkout_viewmodel.dart';
import '../../widgets/checkout_components.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    this.onManageAddress,
    this.onOpenPaymentUrl,
  });

  final VoidCallback? onManageAddress;
  final ValueChanged<String>? onOpenPaymentUrl;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final TextEditingController _voucherController;

  @override
  void initState() {
    super.initState();
    _voucherController = TextEditingController(
      text: ref.read(checkoutViewModelProvider).voucherCode,
    );
    Future.microtask(() {
      if (!mounted) return;
      final cartState = ref.read(cartViewModelProvider);
      final cartIsBusy =
          cartState.isLoading ||
          cartState.isAdding ||
          cartState.isUpdating ||
          cartState.isRemoving ||
          cartState.isClearing;
      ref
          .read(checkoutViewModelProvider.notifier)
          .loadCheckout(initialCart: cartIsBusy ? null : cartState.cart);
    });
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutViewModelProvider);
    ref.listen(
      checkoutViewModelProvider.select((value) => value.orderErrorMessage),
      (previous, next) {
        if (next == null || next == previous || !mounted) return;
        _showMessage(next);
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Thanh toán'),
        centerTitle: false,
      ),
      body: _buildBody(state),
      bottomNavigationBar: _shouldShowAction(state)
          ? _buildBottomAction(state)
          : null,
    );
  }

  Widget _buildBody(CheckoutState state) {
    if (state.isLoading && state.cartItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.loadErrorMessage != null && state.cartItems.isEmpty) {
      return CheckoutMessageState(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải giỏ hàng',
        message: 'Vui lòng kiểm tra kết nối và thử lại.',
        actionLabel: 'Thử lại',
        onAction: _loadCheckout,
      );
    }

    if (state.cartItems.isEmpty) {
      return const CheckoutMessageState(
        icon: Icons.shopping_bag_outlined,
        title: 'Giỏ hàng đang trống',
        message: 'Thêm sản phẩm vào giỏ trước khi thanh toán.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCheckout,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (state.loadErrorMessage != null)
            CheckoutInlineNotice(
              message: 'Không thể làm mới giỏ hàng. ${state.loadErrorMessage}',
              isError: true,
              actionLabel: 'Thử lại',
              onAction: _loadCheckout,
            ),
          if (state.addressErrorMessage != null)
            CheckoutInlineNotice(
              message: 'Không thể tải địa chỉ. Vui lòng thử tải lại.',
              isError: true,
              actionLabel: 'Thử lại',
              onAction: _loadCheckout,
            ),
          _sectionHeading('Địa chỉ giao hàng'),
          const SizedBox(height: 10),
          _buildAddress(state),
          const SizedBox(height: 24),
          _sectionHeading(
            'Sản phẩm',
            trailing: '${state.cartItems.length} món',
          ),
          const SizedBox(height: 10),
          ...state.cartItems.map((item) => CheckoutProductLine(item: item)),
          const SizedBox(height: 14),
          _buildVoucher(state),
          const SizedBox(height: 24),
          _sectionHeading('Phương thức thanh toán'),
          const SizedBox(height: 10),
          CheckoutPaymentOption(
            title: 'Thanh toán khi nhận hàng',
            subtitle: 'COD · Trả tiền khi nhận sản phẩm',
            icon: Icons.local_shipping_outlined,
            selected: state.paymentMethod == OrderPaymentMethod.cod,
            enabled: state.createdOrder == null && !state.isSubmitting,
            onTap: () => ref
                .read(checkoutViewModelProvider.notifier)
                .setPaymentMethod(OrderPaymentMethod.cod),
          ),
          const SizedBox(height: 8),
          CheckoutPaymentOption(
            title: 'Thanh toán qua VNPAY',
            subtitle: 'Chuyển đến cổng thanh toán sau khi đặt hàng',
            icon: Icons.account_balance_wallet_outlined,
            selected: state.paymentMethod == OrderPaymentMethod.vnpay,
            enabled: state.createdOrder == null && !state.isSubmitting,
            onTap: () => ref
                .read(checkoutViewModelProvider.notifier)
                .setPaymentMethod(OrderPaymentMethod.vnpay),
          ),
          const SizedBox(height: 24),
          _sectionHeading('Tóm tắt đơn hàng'),
          const SizedBox(height: 10),
          _buildSummary(state),
          if (state.createdOrder != null) ...[
            const SizedBox(height: 16),
            _buildOrderResult(state),
          ],
          if (state.paymentErrorMessage != null && state.createdOrder != null)
            CheckoutInlineNotice(
              message: state.paymentErrorMessage!,
              isError: true,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAddress(CheckoutState state) {
    final address = state.selectedAddress;
    if (address == null) {
      return CheckoutCardSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              state.addresses.isEmpty
                  ? 'Bạn chưa có địa chỉ nhận hàng'
                  : 'Chọn địa chỉ nhận hàng',
              style: AppFonts.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm địa chỉ để tiếp tục đặt hàng.',
              style: AppFonts.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: state.addresses.isEmpty
                  ? (widget.onManageAddress ?? _showAddressUnavailable)
                  : () => _showAddressPicker(state),
              icon: Icon(
                state.addresses.isEmpty
                    ? Icons.add_location_alt_outlined
                    : Icons.location_on_outlined,
              ),
              label: Text(
                state.addresses.isEmpty
                    ? 'Thêm địa chỉ'
                    : 'Chọn địa chỉ đã lưu',
              ),
            ),
          ],
        ),
      );
    }

    return CheckoutCardSurface(
      onTap: state.createdOrder == null && !state.isSubmitting
          ? () => _showAddressPicker(state)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(address.fullName, style: AppFonts.bodyMedium),
                    if (address.isDefault) const CheckoutTag(label: 'Mặc định'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address.phone, style: checkoutSecondaryText),
                const SizedBox(height: 4),
                Text(
                  checkoutAddressText(address),
                  style: AppFonts.body.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          if (state.createdOrder == null)
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildVoucher(CheckoutState state) {
    final locked = state.createdOrder != null || state.isSubmitting;
    return CheckoutCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Mã giảm giá', style: AppFonts.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  enabled: !locked && !state.isValidatingVoucher,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onChanged: ref
                      .read(checkoutViewModelProvider.notifier)
                      .updateVoucherCode,
                  onSubmitted: (_) => _applyVoucher(state),
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã voucher',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: locked || state.isValidatingVoucher
                      ? null
                      : () => _applyVoucher(state),
                  child: state.isValidatingVoucher
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Áp dụng'),
                ),
              ),
            ],
          ),
          if (state.validatedVoucher != null) ...[
            const SizedBox(height: 10),
            CheckoutInlineNotice(
              message:
                  'Đã áp dụng ${state.validatedVoucher!.voucher.code} · giảm ${PriceFormatter.format(state.validatedVoucher!.discount)}',
              isError: false,
            ),
          ],
          if (state.voucherErrorMessage != null) ...[
            const SizedBox(height: 8),
            CheckoutInlineNotice(
              message: state.voucherErrorMessage!,
              isError: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(CheckoutState state) {
    final order = state.createdOrder;
    final voucherDiscount = state.validatedVoucher?.discount;
    return CheckoutCardSurface(
      child: Column(
        children: [
          CheckoutSummaryRow(
            label: 'Tạm tính',
            value: order == null
                ? 'Xác nhận sau khi đặt hàng'
                : PriceFormatter.format(order.subtotal),
          ),
          if (voucherDiscount != null || order != null) ...[
            const SizedBox(height: 12),
            CheckoutSummaryRow(
              label: 'Voucher',
              value: order != null
                  ? '- ${PriceFormatter.format(order.discount)}'
                  : '- ${PriceFormatter.format(voucherDiscount!)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 12),
          CheckoutSummaryRow(
            label: 'Phí vận chuyển',
            value: order == null
                ? 'Xác nhận sau khi đặt hàng'
                : PriceFormatter.format(order.shippingFee),
          ),
          const SizedBox(height: 12),
          CheckoutSummaryRow(
            label: 'VAT',
            value: order == null
                ? 'Xác nhận sau khi đặt hàng'
                : PriceFormatter.format(order.tax),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.border),
          ),
          CheckoutSummaryRow(
            label: 'Tổng cộng',
            value: order == null
                ? 'Backend xác nhận khi đặt hàng'
                : PriceFormatter.format(order.total),
            emphasize: true,
          ),
          if (order == null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chi phí chính thức sẽ được tính ở máy chủ.',
                style: AppFonts.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderResult(CheckoutState state) {
    final order = state.createdOrder!;
    if (order.paymentMethod == OrderPaymentMethod.cod.name) {
      return CheckoutInlineNotice(
        message: 'Đặt hàng thành công. Mã đơn: ${order.id}',
        isError: false,
      );
    }

    final paymentSession = state.paymentSession;
    if (paymentSession == null) {
      return CheckoutInlineNotice(
        message: state.isCreatingPaymentSession
            ? 'Đơn hàng đã tạo. Đang khởi tạo thanh toán VNPAY…'
            : 'Đơn hàng đã tạo. Tiếp tục để khởi tạo thanh toán VNPAY.',
        isError: false,
      );
    }

    return CheckoutCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đơn hàng đã tạo', style: AppFonts.bodyMedium),
          const SizedBox(height: 4),
          Text('Mã đơn: ${order.id}', style: checkoutSecondaryText),
          const SizedBox(height: 12),
          Text('Liên kết thanh toán VNPAY', style: AppFonts.bodyMedium),
          const SizedBox(height: 4),
          SelectableText(
            paymentSession.paymentUrl,
            style: AppFonts.caption.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 8),
          Text(
            'Mở liên kết này trong trình duyệt để hoàn tất thanh toán.',
            style: checkoutSecondaryText,
          ),
          if (widget.onOpenPaymentUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    widget.onOpenPaymentUrl!(paymentSession.paymentUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Mở thanh toán'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(CheckoutState state) {
    final order = state.createdOrder;
    final isRetryingPayment =
        order?.paymentMethod == OrderPaymentMethod.vnpay.name &&
        state.paymentSession == null &&
        state.paymentErrorMessage != null;
    final canSubmit =
        !state.isLoading &&
        !state.isSubmitting &&
        !state.isValidatingVoucher &&
        !state.isCreatingPaymentSession &&
        state.loadErrorMessage == null &&
        state.addressErrorMessage == null &&
        state.cartItems.isNotEmpty &&
        state.selectedAddress != null &&
        (state.voucherCode.trim().isEmpty || state.validatedVoucher != null) &&
        order == null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: state.isSubmitting || state.isCreatingPaymentSession
                ? null
                : isRetryingPayment
                ? () => ref
                      .read(checkoutViewModelProvider.notifier)
                      .retryVnpayPayment()
                : canSubmit
                ? _submitOrder
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(
                alpha: 0.35,
              ),
            ),
            child: state.isSubmitting || state.isCreatingPaymentSession
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    isRetryingPayment
                        ? 'Thử lại thanh toán'
                        : order != null
                        ? 'Đã đặt hàng'
                        : 'Đặt hàng',
                    style: AppFonts.bodyMedium.copyWith(color: AppColors.white),
                  ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowAction(CheckoutState state) =>
      state.cartItems.isNotEmpty || state.isLoading;

  Widget _sectionHeading(String title, {String? trailing}) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppFonts.title)),
        if (trailing != null)
          Text(
            trailing,
            style: AppFonts.caption.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Future<void> _applyVoucher(CheckoutState state) async {
    if (state.isValidatingVoucher || state.isSubmitting) return;
    ref
        .read(checkoutViewModelProvider.notifier)
        .updateVoucherCode(_voucherController.text);
    await ref.read(checkoutViewModelProvider.notifier).validateVoucher();
  }

  Future<void> _submitOrder() async {
    final order = await ref
        .read(checkoutViewModelProvider.notifier)
        .submitOrder();
    if (!mounted || order == null) return;

    if (order.paymentMethod == OrderPaymentMethod.cod.name) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
          ),
          title: const Text('Đặt hàng thành công'),
          content: Text('Mã đơn hàng: ${order.id}'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showAddressPicker(CheckoutState state) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chọn địa chỉ giao hàng', style: AppFonts.title),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final address = state.addresses[index];
                    final selected = address.id == state.selectedAddress?.id;
                    return CheckoutCardSurface(
                      onTap: () {
                        ref
                            .read(checkoutViewModelProvider.notifier)
                            .selectAddress(address.id);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CheckoutAddressDetails(address: address),
                          ),
                          if (address.isDefault)
                            const CheckoutTag(label: 'Mặc định'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadCheckout() =>
      ref.read(checkoutViewModelProvider.notifier).loadCheckout();

  void _showAddressUnavailable() => _showMessage(
    'Chức năng thêm địa chỉ chưa khả dụng. Bạn có thể chọn địa chỉ đã lưu.',
  );

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
