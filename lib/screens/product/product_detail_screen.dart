import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/models/product_variant_model.dart';
import 'package:shoe_store/viewmodels/cart_provider.dart';
import 'package:shoe_store/widgets/product/product_description.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../viewmodels/product_detail_provider.dart';
import '../../widgets/common/quantity_selector.dart';
import '../../viewmodels/review_provider.dart';
import '../../widgets/product/related_products.dart';
import '../../widgets/product/review_section.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(productDetailViewModelProvider.notifier)
          .loadProduct(widget.productId);

      ref
          .read(reviewViewModelProvider.notifier)
          .loadProductReviews(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailViewModelProvider);
    final reviewState = ref.watch(reviewViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(state.errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final product = state.product;

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy sản phẩm')),
      );
    }

    final variants = product.variants;

    final colors = variants
        .map((variant) => variant.colorName)
        .toSet()
        .toList();

    final sizes =
        variants
            .where((variant) => variant.stock > 0)
            .map((variant) => variant.size)
            .toSet()
            .toList()
          ..sort();

    final displayImage = state.selectedVariant?.image.isNotEmpty == true
        ? state.selectedVariant!.image
        : product.image;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProductImage(imageUrl: displayImage)),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductInfo(product: product),

                  const SizedBox(height: 24),

                  if (colors.isNotEmpty)
                    _ColorSelector(
                      colors: colors,
                      selectedColor: state.selectedColor,
                      variants: variants,
                      onSelected: (color) {
                        ref
                            .read(productDetailViewModelProvider.notifier)
                            .selectColor(color);
                      },
                    ),

                  if (colors.isNotEmpty) const SizedBox(height: 24),

                  if (sizes.isNotEmpty)
                    _SizeSelector(
                      sizes: sizes,
                      selectedSize: state.selectedSize,
                      selectedColor: state.selectedColor,
                      variants: variants,
                      onSelected: (size) {
                        ref
                            .read(productDetailViewModelProvider.notifier)
                            .selectSize(size);
                      },
                    ),

                  if (sizes.isNotEmpty) const SizedBox(height: 24),

                  if (state.selectedVariant != null)
                    _QuantitySection(
                      quantity: state.quantity,
                      maxQuantity: state.selectedVariant!.stock,
                      onDecrease: () {
                        ref
                            .read(productDetailViewModelProvider.notifier)
                            .decreaseQuantity();
                      },
                      onIncrease: () {
                        ref
                            .read(productDetailViewModelProvider.notifier)
                            .increaseQuantity();
                      },
                    ),

                  const SizedBox(height: 24),

                  ProductDescription(description: product.description),

                  const SizedBox(height: 24),

                  ReviewSection(
                    isLoading: reviewState.isLoading,
                    reviews: reviewState.reviews,
                    errorMessage: reviewState.errorMessage,
                  ),

                  const SizedBox(height: 24),

                  RelatedProducts(products: state.relatedProducts),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _BottomActions(
        onAddToCart: _addToCart,
        onBuyNow: _buyNow,
        isAdding: ref.watch(cartViewModelProvider).isAdding,
      ),
    );
  }

  Future<void> _addToCart() async {
    final productState = ref.read(productDetailViewModelProvider);

    if (productState.selectedVariant == null) {
      _showMessage('Vui lòng chọn màu sắc và kích thước');
      return;
    }

    // Không cho gửi nhiều request cùng lúc
    final cartState = ref.read(cartViewModelProvider);

    if (cartState.isAdding) {
      return;
    }

    final variant = productState.selectedVariant!;

    await ref
        .read(cartViewModelProvider.notifier)
        .addToCart(
          productId: productState.product!.id,
          variantId: variant.id,
          quantity: productState.quantity,
        );

    if (!mounted) return;

    final updatedCartState = ref.read(cartViewModelProvider);

    // API lỗi → chỉ hiện lỗi và dừng
    if (updatedCartState.errorMessage != null) {
      _showMessage(updatedCartState.errorMessage!);
      return;
    }

    // API thành công
    _showMessage('Đã thêm ${productState.quantity} sản phẩm vào giỏ hàng');
  }

  Future<void> _buyNow() {
    final state = ref.read(productDetailViewModelProvider);

    if (state.selectedVariant == null) {
      _showMessage('Vui lòng chọn màu sắc và kích thước');
      return Future.value();
    }

    _showMessage('Mua ${state.quantity} sản phẩm');
    return Future.value();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      width: double.infinity,
      color: AppColors.white,
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.image_outlined,
              size: 64,
              color: AppColors.textSecondary,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.broken_image_outlined, size: 64);
              },
            ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final dynamic product;

  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (product.brand != null)
              Text(
                product.brand!.name,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.accent),
              ),

            const SizedBox(width: 8),

            if (product.category != null)
              Text(
                '• ${product.category!.name}',
                style: AppFonts.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Text(product.name, style: AppFonts.headingMedium),

        const SizedBox(height: 12),

        Row(
          children: [
            const Icon(Icons.star, size: 18, color: AppColors.warning),

            const SizedBox(width: 4),

            Text(product.rating.toStringAsFixed(1), style: AppFonts.bodyMedium),

            const SizedBox(width: 8),

            Text(
              '|',
              style: AppFonts.body.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(width: 8),

            Text(
              'Đã bán ${product.sold}',
              style: AppFonts.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatPrice(product.displayPrice),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),

            if (product.hasDiscount) ...[
              const SizedBox(width: 10),

              Text(
                _formatPrice(product.price),
                style: const TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  static String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (match) => '${match.group(1)}.')}đ';
  }
}

class _ColorSelector extends StatelessWidget {
  final List<String> colors;
  final String? selectedColor;
  final List<ProductVariantModel> variants;
  final ValueChanged<String> onSelected;

  const _ColorSelector({
    required this.colors,
    required this.selectedColor,
    required this.variants,
    required this.onSelected,
  });

  ProductVariantModel? _getColorVariant(String colorName) {
    for (final variant in variants) {
      if (variant.colorName == colorName && variant.stock > 0) {
        return variant;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Màu sắc', style: AppFonts.bodyMedium),

        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorName) {
            final isSelected = colorName == selectedColor;
            final variant = _getColorVariant(colorName);

            return _ColorItem(
              colorName: colorName,
              colorCode: variant?.colorCode,
              isSelected: isSelected,
              onTap: () => onSelected(colorName),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ColorItem extends StatelessWidget {
  final String colorName;
  final String? colorCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorItem({
    required this.colorName,
    required this.colorCode,
    required this.isSelected,
    required this.onTap,
  });

  Color _parseColor(String? colorCode) {
    if (colorCode == null || colorCode!.isEmpty) {
      return AppColors.border;
    }

    try {
      final hex = colorCode!.replaceFirst('#', '');

      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }

      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }

      return AppColors.border;
    } catch (_) {
      return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(colorCode);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: color == Colors.white
                      ? AppColors.border
                      : Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            colorName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final List<int> sizes;
  final int? selectedSize;
  final String? selectedColor;
  final List<ProductVariantModel> variants;
  final ValueChanged<int> onSelected;

  const _SizeSelector({
    required this.sizes,
    required this.selectedSize,
    required this.onSelected,
    this.selectedColor,
    required this.variants,
  });

  bool _isSizeAvailable(int size) {
    if (selectedColor == null) {
      return false;
    }
    return variants.any(
      (variant) =>
          variant.colorName == selectedColor &&
          variant.size == size &&
          variant.stock > 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kích thước', style: AppFonts.bodyMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sizes.map((size) {
            final isSelected = size == selectedSize;
            final isAvailable = _isSizeAvailable(size);

            return _SizeItem(
              size: size,
              isSelected: isSelected,
              isAvailable: isAvailable,
              onTap: isAvailable ? () => onSelected(size) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SizeItem extends StatelessWidget {
  final int size;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _SizeItem({
    required this.size,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: !isAvailable
              ? AppColors.background
              : isSelected
              ? AppColors.primary
              : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: !isAvailable
                ? AppColors.border
                : isSelected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Text(
          size.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: !isAvailable
                ? AppColors.textSecondary
                : isSelected
                ? AppColors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _QuantitySection extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantitySection({
    required this.quantity,
    required this.maxQuantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Số lượng', style: AppFonts.title),

        QuantitySelector(
          quantity: quantity,
          maxQuantity: maxQuantity,
          onDecrease: onDecrease,
          onIncrease: onIncrease,
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isAdding;

  const _BottomActions({
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isAdding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isAdding ? null : onAddToCart,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Thêm vào giỏ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onBuyNow,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Mua ngay',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
