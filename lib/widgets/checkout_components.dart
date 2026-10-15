import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/utils/price_formatter.dart';
import '../models/address_model.dart';
import '../models/cart_model.dart';

class CheckoutProductLine extends StatelessWidget {
  const CheckoutProductLine({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return CheckoutCardSurface(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 76,
              height: 88,
              child: item.image.isEmpty
                  ? const ColoredBox(
                      color: AppColors.background,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppColors.background,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.bodyMedium.copyWith(height: 1.3),
                ),
                const SizedBox(height: 5),
                Text(
                  'Màu: ${item.colorName} · Size: ${item.size}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: checkoutSecondaryText,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      PriceFormatter.format(item.finalPrice),
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text('× ${item.quantity}', style: checkoutSecondaryText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutAddressDetails extends StatelessWidget {
  const CheckoutAddressDetails({super.key, required this.address});

  final AddressModel address;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(address.fullName, style: AppFonts.bodyMedium),
      const SizedBox(height: 3),
      Text(address.phone, style: checkoutSecondaryText),
      const SizedBox(height: 3),
      Text(checkoutAddressText(address), style: checkoutSecondaryText),
    ],
  );
}

class CheckoutPaymentOption extends StatelessWidget {
  const CheckoutPaymentOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    enabled: enabled,
    label: '$title. $subtitle',
    child: CheckoutCardSurface(
      onTap: enabled ? onTap : null,
      borderColor: selected ? AppColors.accent : AppColors.border,
      child: Row(
        children: [
          Icon(
            icon,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.bodyMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: checkoutSecondaryText),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}

class CheckoutSummaryRow extends StatelessWidget {
  const CheckoutSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: emphasize ? AppFonts.bodyMedium : checkoutSecondaryText,
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: (emphasize ? AppFonts.bodyMedium : AppFonts.body).copyWith(
            color:
                valueColor ??
                (emphasize ? AppColors.primary : AppColors.textPrimary),
            fontWeight: emphasize ? FontWeight.w700 : null,
          ),
        ),
      ),
    ],
  );
}

class CheckoutInlineNotice extends StatelessWidget {
  const CheckoutInlineNotice({
    super.key,
    required this.message,
    required this.isError,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppFonts.body.copyWith(color: color)),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutMessageState extends StatelessWidget {
  const CheckoutMessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: AppFonts.title),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFonts.body.copyWith(color: AppColors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}

class CheckoutCardSurface extends StatelessWidget {
  const CheckoutCardSurface({
    super.key,
    required this.child,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(14),
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: card,
      ),
    );
  }
}

class CheckoutTag extends StatelessWidget {
  const CheckoutTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: AppFonts.caption.copyWith(
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String checkoutAddressText(AddressModel address) => [
  address.addressDetail,
  address.ward,
  address.district,
  address.province,
].where((part) => part.trim().isNotEmpty).join(', ');

TextStyle get checkoutSecondaryText =>
    AppFonts.body.copyWith(color: AppColors.textSecondary, height: 1.35);
