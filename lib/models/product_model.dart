import 'package:shoe_store/models/product_variant_model.dart';

import 'brand_model.dart';
import 'category_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String image;
  final BrandModel? brand;
  final CategoryModel? category;
  final int sold;
  final double rating;
  final bool isFeatured;
  final String status;
  final List<ProductVariantModel> variants;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.image,
    this.brand,
    this.category,
    required this.sold,
    required this.rating,
    required this.isFeatured,
    required this.status,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final brandJson = json['brand'];
    final categoryJson = json['category'];

    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice:
          json['discountPrice'] != null &&
              (json['discountPrice'] as num).toDouble() > 0
          ? (json['discountPrice'] as num).toDouble()
          : null,
      image: json['image'] ?? '',
      brand: brandJson is Map<String, dynamic>
          ? BrandModel.fromJson(brandJson)
          : null,
      category: categoryJson is Map<String, dynamic>
          ? CategoryModel.fromJson(categoryJson)
          : null,
      sold: json['sold'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      isFeatured: json['isFeatured'] ?? false,
      status: json['status'] ?? '',
      variants:
          (json['variants'] as List?)
              ?.map(
                (v) => ProductVariantModel.fromJson(v as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  bool get hasDiscount {
    return discountPrice != null &&
        discountPrice! > 0 &&
        discountPrice! < price;
  }

  double get displayPrice {
    return hasDiscount ? discountPrice! : price;
  }
}
