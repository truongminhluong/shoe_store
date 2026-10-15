import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onCartPressed;

  const HomeHeader({super.key, this.onCartPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RYDE',
                style: TextStyle(
                  fontSize: 28,
                  height: 1,
                  letterSpacing: -1.4,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'SNEAKERS  /  STREETWEAR',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Giỏ hàng',
          onPressed: onCartPressed,
          icon: const Icon(Icons.shopping_bag_outlined),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: AppColors.primary,
            backgroundColor: const Color(0xFFF2F5FA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
