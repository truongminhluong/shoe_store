import 'package:flutter/material.dart';
import 'package:shoe_store/core/constants/app_colors.dart';
import 'package:shoe_store/core/constants/app_fonts.dart';
import 'package:shoe_store/core/utils/price_formatter.dart';

import '../../../models/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;
  final bool isUpdating;
  final bool isBusy;

  const CartItemCard({
    super.key,
    required this.item,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
    required this.isUpdating,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          const SizedBox(width: 12),
          Expanded(child: _buildProductInfo()),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        height: 96,
        color: AppColors.background,
        child: Image.network(
          item.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_not_supported_outlined,
              size: 30,
              color: AppColors.textSecondary,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 2),
        _buildVariant(),
        const SizedBox(height: 2),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.25,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _RemoveButton(
          semanticLabel: 'Xóa ${item.name} khỏi giỏ hàng',
          onPressed: onRemove,
        ),
      ],
    );
  }

  Widget _buildVariant() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _parseColor(item.colorCode),
                border: Border.all(color: AppColors.border),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Màu: ${item.colorName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _variantStyle,
              ),
            ),
          ],
        ),
        Text('Size: ${item.size}', style: _variantStyle),
      ],
    );
  }

  TextStyle get _variantStyle =>
      AppFonts.caption.copyWith(color: AppColors.textSecondary, fontSize: 13);

  Color _parseColor(String code) {
    final normalized = code.replaceFirst('#', '');
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return AppColors.border;
    return Color(normalized.length == 6 ? 0xFF000000 | value : value);
  }

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.discountPrice > 0)
                Text(
                  PriceFormatter.format(item.price),
                  style: AppFonts.caption.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                PriceFormatter.format(item.finalPrice),
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        _buildQuantityControls(),
      ],
    );
  }

  bool get _atStockLimit => item.quantity >= item.stock;

  Widget _buildQuantityControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove,
                semanticLabel: 'Giảm số lượng ${item.name}',
                onPressed: isBusy || item.quantity <= 1 ? null : onDecrease,
              ),
              SizedBox(
                width: 30,
                child: Center(
                  child: isUpdating
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          '${item.quantity}',
                          style: AppFonts.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                semanticLabel: 'Tăng số lượng ${item.name}',
                onPressed: isBusy || _atStockLimit ? null : onIncrease,
              ),
            ],
          ),
        ),
        if (_atStockLimit) ...[
          const SizedBox(height: 4),
          Text(
            'Đã đạt giới hạn tồn kho (${item.stock})',
            textAlign: TextAlign.right,
            style: AppFonts.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String semanticLabel;

  const _RemoveButton({required this.onPressed, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      tooltip: semanticLabel,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.close, size: 18),
      color: AppColors.textSecondary,
      splashRadius: 18,
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        tooltip: semanticLabel,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 15),
        color: AppColors.textPrimary,
        disabledColor: AppColors.border,
      ),
    );
  }
}
