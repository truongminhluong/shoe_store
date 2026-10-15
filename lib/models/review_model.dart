class ReviewUserModel {
  final String id;
  final String fullName;
  final String avatar;

  const ReviewUserModel({
    required this.id,
    required this.fullName,
    required this.avatar,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class ReviewModel {
  final String id;
  final ReviewUserModel user;
  final String productId;
  final String orderId;
  final int rating;
  final String comment;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.user,
    required this.productId,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return ReviewModel(
      id: json['_id'] ?? '',
      user: userJson is Map<String, dynamic>
          ? ReviewUserModel.fromJson(userJson)
          : const ReviewUserModel(id: '', fullName: 'Người dùng', avatar: ''),
      productId: json['product'] ?? '',
      orderId: json['order'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] ?? '',
      images:
          (json['images'] as List?)
              ?.map((image) => image.toString())
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
