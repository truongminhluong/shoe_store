import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/review_model.dart';

class ReviewItem extends StatelessWidget {
  final ReviewModel review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserName(),

                const SizedBox(height: 5),

                _buildRating(),

                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  _buildComment(),
                ],

                if (review.createdAt != null) ...[
                  const SizedBox(height: 6),
                  _buildDate(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (review.user.avatar.isEmpty) {
      return const CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.border,
        child: Icon(
          Icons.person_outline,
          size: 22,
          color: AppColors.textSecondary,
        ),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.border,
      backgroundImage: NetworkImage(review.user.avatar),
    );
  }

  Widget _buildUserName() {
    return Text(
      review.user.fullName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < review.rating;

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 17,
            color: AppColors.warning,
          ),
        );
      }),
    );
  }

  Widget _buildComment() {
    return Text(
      review.comment,
      style: const TextStyle(
        fontSize: 14,
        height: 1.35,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDate() {
    return Text(
      _formatDate(review.createdAt!),
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
