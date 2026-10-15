import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../product/product_card.dart';

class ProductSection extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final VoidCallback onClearSearch;

  const ProductSection({
    super.key,
    required this.products,
    required this.isLoading,
    required this.searchQuery,
    required this.onClearSearch,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Loading
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Error
    if (errorMessage != null) {
      return SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            errorMessage!,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      );
    }

    // Empty
    if (products.isEmpty) {
      if (searchQuery.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 34,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                const Text('Chưa tìm thấy sản phẩm phù hợp'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onClearSearch,
                  child: const Text('Xóa tìm kiếm'),
                ),
              ],
            ),
          ),
        );
      }

      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('Không có sản phẩm'),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        // Section title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              searchQuery.isEmpty ? 'Hàng mới về' : 'Kết quả tìm kiếm',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),

        SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final crossAxisCount = width >= 920
                ? 4
                : width >= 620
                ? 3
                : 2;
            const spacing = 16.0;
            final tileWidth =
                (width - spacing * (crossAxisCount - 1)) / crossAxisCount;

            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverGrid.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: 24,
                  mainAxisExtent: tileWidth + 156,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    productId: product.id,
                    name: product.name,
                    brand: product.brand?.name ?? '',
                    imageUrl: product.image,
                    price: product.price,
                    discountPrice: product.discountPrice,
                    rating: product.rating,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
