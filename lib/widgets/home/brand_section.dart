import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/brand_model.dart';

class BrandSection extends StatelessWidget {
  final List<BrandModel> brands;

  const BrandSection({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thương hiệu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 76,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: index == brands.length - 1 ? 0 : 12,
                ),
                child: _BrandItem(brand: brand),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandItem extends StatelessWidget {
  final BrandModel brand;

  const _BrandItem({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.network(
              brand.logo,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.textSecondary,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            brand.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
