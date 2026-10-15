import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import 'product_card.dart';

class RelatedProducts extends StatelessWidget {
  final List<ProductModel> products;

  const RelatedProducts({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm tương tự',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            mainAxisExtent: 340,
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
      ],
    );
  }
}
