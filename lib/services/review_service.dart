import 'dart:convert';

import 'package:shoe_store/models/review_model.dart';

import '../core/network/api_client.dart';

class ReviewService {
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final response = await ApiClient.get('/reviews/product/$productId');
    final data = response['data'];

    if (data is! List) {
      throw Exception('Dữ liệu đánh giá sản phẩm không hợp lệ');
    }

    return data
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
