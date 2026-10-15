import 'package:shoe_store/models/product_model.dart';
import 'package:shoe_store/services/product_service.dart';

import '../models/product_variant_model.dart';

class ProductRepository {
  final ProductService _productService;

  ProductRepository({ProductService? productService})
    : _productService = productService ?? ProductService();

  Future<List<ProductModel>> getProducts() {
    return _productService.getProducts();
  }

  Future<ProductModel> getProductById(String productId) {
    return _productService.getProductById(productId);
  }

  Future<List<ProductVariantModel>> getProductVariants(String productId) {
    return _productService.getProductVariants(productId);
  }

}
