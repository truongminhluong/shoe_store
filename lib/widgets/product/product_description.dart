import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProductDescription extends StatefulWidget {
  final String description;

  const ProductDescription({super.key, required this.description});

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.description.trim().isNotEmpty;

    if (!hasDescription) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mô tả sản phẩm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          widget.description,
          maxLines: _isExpanded ? null : 4,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        _buildToggleButton(),
      ],
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isExpanded ? 'Thu gọn' : 'Xem thêm',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 4),

          Icon(
            _isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
