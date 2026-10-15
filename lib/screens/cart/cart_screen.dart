import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/viewmodels/cart_viewmodel.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/cart_provider.dart';
import '../../widgets/cart/cart_item_card.dart';
import '../../widgets/cart/cart_summary.dart';

class CartScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinueShopping;

  const CartScreen({super.key, this.onContinueShopping});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isOpeningCheckout = false;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(cartViewModelProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(cartViewModelProvider.select((state) => state.errorMessage), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      final cart = ref.read(cartViewModelProvider).cart;
      if (cart == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật giỏ hàng. Vui lòng thử lại.'),
          ),
        );
    });
    final state = ref.watch(cartViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CartState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.cart == null) {
      return _buildError(state.errorMessage!);
    }

    if (state.isEmpty) {
      return _buildEmptyCart();
    }

    return _buildCartList(state);
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(cartViewModelProvider.notifier).loadCart();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Giỏ hàng đang trống',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm sản phẩm yêu thích vào giỏ hàng.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: widget.onContinueShopping,
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(CartState state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];

              return CartItemCard(
                item: item,
                isUpdating: state.updatingVariantIds.contains(item.variantId),
                isBusy: state.updatingVariantIds.contains(item.variantId),
                onIncrease: () {
                  ref
                      .read(cartViewModelProvider.notifier)
                      .updateCartItem(
                        variantId: item.variantId,
                        quantity: item.quantity + 1,
                      );
                },
                onDecrease: () {
                  if (item.quantity <= 1) return;

                  ref
                      .read(cartViewModelProvider.notifier)
                      .updateCartItem(
                        variantId: item.variantId,
                        quantity: item.quantity - 1,
                      );
                },
                onRemove: () {
                  _showRemoveConfirmation(item.variantId);
                },
              );
            },
          ),
        ),
        CartSummary(
          subtotal: state.subtotal,
          totalQuantity: state.totalQuantity,
          onCheckout: _onCheckout,
        ),
      ],
    );
  }

  void _onCheckout() {
    if (_isOpeningCheckout) return;
    setState(() => _isOpeningCheckout = true);
    Navigator.of(context).pushNamed(AppRoutes.checkout).whenComplete(() {
      if (mounted) setState(() => _isOpeningCheckout = false);
    });
  }

  Future<void> _showRemoveConfirmation(String variantId) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: const Text(
            'Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) return;

    if (!mounted) return;

    await ref
        .read(cartViewModelProvider.notifier)
        .removeFromCart(variantId: variantId);
  }
}
