import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = quantity > 1;
    final canIncrease = quantity < maxQuantity;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDecrease ? onDecrease : null,
            icon: const Icon(Icons.remove, size: 18),
          ),

          Text(
            '$quantity',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          IconButton(
            onPressed: canIncrease ? onIncrease : null,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
