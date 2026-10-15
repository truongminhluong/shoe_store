import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final String brand;
  final String imageUrl;
  final double price;
  final double? discountPrice;
  final double rating;

  const ProductCard({
    super.key,
    required this.productId,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.price,
    this.discountPrice,
    required this.rating,
  });

  // Có giảm giá hay không
  bool get hasDiscount {
    return discountPrice != null && discountPrice! < price;
  }

  // Tính phần trăm giảm giá
  double get discountPercent {
    if (!hasDiscount) {
      return 0;
    }

    return ((price - discountPrice!) / price) * 100;
  }

  // Format:
  // 1990000 -> 1.990.000đ
  String formatPrice(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetail,
            arguments: productId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // PRODUCT IMAGE
              // =========================
              _ProductImage(
                imageUrl: imageUrl,
                semanticLabel: name,
                hasDiscount: hasDiscount,
                discountPercent: discountPercent,
              ),

              // =========================
              // PRODUCT INFO
              // =========================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand
                      Text(
                        brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Product name
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Original price
                      if (hasDiscount) ...[
                        Text(
                          formatPrice(price),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],

                      // Final price
                      Text(
                        formatPrice(hasDiscount ? discountPrice! : price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PRODUCT IMAGE
// =====================================================

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final String semanticLabel;
  final bool hasDiscount;
  final double discountPercent;

  const _ProductImage({
    required this.imageUrl,
    required this.semanticLabel,
    required this.hasDiscount,
    required this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // =========================
        // IMAGE
        // =========================
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: const Color(0xFFF4F6F9),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              semanticLabel: semanticLabel,

              // Loading
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },

              // Error
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 32,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),

        // =========================
        // DISCOUNT BADGE
        // =========================
        if (hasDiscount)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${discountPercent.round()}%',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        // =========================
      ],
    );
  }
}
