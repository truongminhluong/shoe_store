import 'package:shoe_store/models/review_model.dart';

import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _reviewService;

  ReviewRepository({
    ReviewService? reviewService,
  }) : _reviewService = reviewService ?? ReviewService();

  Future<List<ReviewModel>> getProductReviews(String productId) {
    return _reviewService.getProductReviews(productId);
  }

}