import 'package:shoe_store/services/cart_service.dart';

import '../models/cart_model.dart';

class CartRepository {
  final CartService _cartService;

  CartRepository(this._cartService);

  //Get cart
  Future<CartModel> getCart() async {
    return await _cartService.getCart();
  }

  // Add to cart
  Future<CartModel> addToCart({
    required String productId,
    required String variantId,
    required int quantity,
  }) async {
    return await _cartService.addToCart(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );
  }

  // Update cart item quantity
  Future<CartModel> updateCartItem({
    required String variantId,
    required int quantity,
  }) async {
    return await _cartService.updateCartItem(
      variantId: variantId,
      quantity: quantity,
    );
  }

  // Remove item from cart
  Future<CartModel> removeFromCart({required String variantId}) async {
    return await _cartService.removeFromCart(variantId: variantId);
  }

  // Clear cart
  Future<CartModel> clearCart() async {
    return await _cartService.clearCart();
  }
}