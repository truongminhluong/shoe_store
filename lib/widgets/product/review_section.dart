import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/review_model.dart';
import 'review_item.dart';

class ReviewSection extends StatelessWidget {
  final bool isLoading;
  final List<ReviewModel> reviews;
  final String? errorMessage;

  const ReviewSection({
    super.key,
    required this.isLoading,
    required this.reviews,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading();
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (reviews.isEmpty) {
      return _buildEmpty();
    }

    return _buildReviews();
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Không thể tải đánh giá',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Chưa có đánh giá nào',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildReviews() {
    final previewReviews = reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),

        const SizedBox(height: 20),

        _buildSummary(),

        const SizedBox(height: 24),

        ...previewReviews.map((review) => ReviewItem(review: review)),

        if (reviews.length > 3) ...[
          const SizedBox(height: 4),
          _buildViewAllButton(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Đánh giá sản phẩm',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSummary() {
    final averageRating = _calculateAverageRating();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStars(averageRating),

                const SizedBox(height: 5),

                Text(
                  '${reviews.length} đánh giá',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          size: 18,
          color: AppColors.warning,
        );
      }),
    );
  }

  Widget _buildViewAllButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Mở màn hình tất cả đánh giá
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Xem tất cả đánh giá',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) {
      return 0;
    }

    final totalRating = reviews.fold<int>(
      0,
      (total, review) => total + review.rating,
    );

    return totalRating / reviews.length;
  }
}
