import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Tìm sneaker, thương hiệu...',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa nội dung tìm kiếm',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
