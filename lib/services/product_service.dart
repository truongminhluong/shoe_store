import 'package:shoe_store/models/product_model.dart';

import '../core/network/api_client.dart';
import '../models/product_variant_model.dart';

class ProductService {
  Future<List<ProductModel>> getProducts() async {
    final response = await ApiClient.get('/products');

    final List<dynamic> data = response['data'];

    if (data is! List) {
      throw Exception('Dữ liệu sản phẩm không hợp lệ');
    }

    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductById(String productId) async {
    final response = await ApiClient.get('/products/$productId');

    return ProductModel.fromJson(response['data']);
  }

  Future<List<ProductVariantModel>> getProductVariants(String productId) async {
    final response = await ApiClient.get('/product-variants/product/$productId');

    final data = response['data'];

    if (data is! List) {
      throw Exception('Dữ liệu biến thể sản phẩm không hợp lệ');
    }

    return data.map((json) => ProductVariantModel.fromJson(json)).toList();
  }

}
