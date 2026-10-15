import '../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartService {
  // GET CART
  Future<CartModel> getCart() async {
    final response = await ApiClient.get('/cart');

    return CartModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ADD TO CART
  Future<CartModel> addToCart({
    required String productId,
    required String variantId,
    required int quantity,
  }) async {
    final response = await ApiClient.post(
      '/cart',
      body: {'product': productId, 'variant': variantId, 'quantity': quantity},
    );

    return CartModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // UPDATE QUANTITY
  Future<CartModel> updateCartItem({
    required String variantId,
    required int quantity,
  }) async {
    final response = await ApiClient.put(
      '/cart/$variantId',
      body: {'quantity': quantity},
    );

    return CartModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // REMOVE ITEM
  Future<CartModel> removeFromCart({required String variantId}) async {
    final response = await ApiClient.delete('/cart/$variantId');

    return CartModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // CLEAR CART
  Future<CartModel> clearCart() async {
    final response = await ApiClient.delete('/cart');

    return CartModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
