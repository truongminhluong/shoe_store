import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoe_store/repositories/review_repository.dart';

import '../models/review_model.dart';

class ReviewState {
  final bool isLoading;
  final List<ReviewModel> reviews;
  final String? errorMessage;

  const ReviewState({
    this.isLoading = false,
    this.reviews = const [],
    this.errorMessage,
  });
}

class ReviewViewmodel extends Notifier<ReviewState> {
  final ReviewRepository _reviewRepository;

  ReviewViewmodel({ReviewRepository? reviewRepository})
    : _reviewRepository = reviewRepository ?? ReviewRepository();

  @override
  ReviewState build() {
    return const ReviewState();
  }

  Future<void> loadProductReviews(String productId) async {
    state = ReviewState(isLoading: true, reviews: state.reviews);

    try {
      final reviews = await _reviewRepository.getProductReviews(productId);
      state = ReviewState(isLoading: false, reviews: reviews);
    } catch (error) {
      state = ReviewState(
        isLoading: false,
        reviews: state.reviews,
        errorMessage: error.toString(),
      );
    }
  }
}
