class ProductVariantModel {
  final String id;
  final String colorName;
  final String colorCode;
  final int size;
  final int stock;
  final String image;

  const ProductVariantModel({
    required this.id,
    required this.colorName,
    required this.colorCode,
    required this.size,
    required this.stock,
    required this.image,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['_id'] ?? json['id'] ?? '',
      colorName: json['colorName'] ?? '',
      colorCode: json['colorCode'] ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      image: json['image'] ?? '',
    );
  }

  bool get isInStock => stock > 0;
}
