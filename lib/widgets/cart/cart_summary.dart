import 'package:flutter/material.dart';
import 'package:shoe_store/core/constants/app_colors.dart';
import 'package:shoe_store/core/constants/app_fonts.dart';
import 'package:shoe_store/core/utils/price_formatter.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final int totalQuantity;
  final VoidCallback? onCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.totalQuantity,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isCartEmpty = totalQuantity <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              label: 'Tạm tính',
              value: PriceFormatter.format(subtotal),
            ),
            const SizedBox(height: 6),
            _buildSummaryRow(
              label: 'Số lượng',
              value: '$totalQuantity sản phẩm',
            ),
            const SizedBox(height: 8),
            Text(
              'Phí vận chuyển, VAT và tổng tiền sẽ được xác nhận tại Checkout.',
              style: AppFonts.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isCartEmpty ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Tiến hành thanh toán',
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppFonts.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
