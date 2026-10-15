class CartItemModel {
  final String productId;
  final String variantId;

  final String name;
  final String image;

  final double price;
  final double discountPrice;

  final String colorName;
  final String colorCode;
  final int size;

  final int quantity;
  final int stock;

  const CartItemModel({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.image,
    required this.price,
    required this.discountPrice,
    required this.colorName,
    required this.colorCode,
    required this.size,
    required this.quantity,
    required this.stock,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    final variant = json['variant'] as Map<String, dynamic>;

    return CartItemModel(
      productId: product['_id'] as String,
      variantId: variant['_id'] as String,

      name: product['name'] as String,
      image: product['image'] as String,

      price: (product['price'] as num).toDouble(),
      discountPrice: (product['discountPrice'] as num?)?.toDouble() ?? 0,

      colorName: variant['colorName'] as String,
      colorCode: variant['colorCode'] as String,
      size: variant['size'] as int,

      quantity: json['quantity'] as int,
      stock: variant['stock'] as int,
    );
  }

  double get finalPrice {
    if (discountPrice > 0) {
      return discountPrice;
    }

    return price;
  }

  double get totalPrice {
    return finalPrice * quantity;
  }

  CartItemModel copyWith({
    String? productId,
    String? variantId,
    String? name,
    String? image,
    double? price,
    double? discountPrice,
    String? colorName,
    String? colorCode,
    int? size,
    int? quantity,
    int? stock,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      colorName: colorName ?? this.colorName,
      colorCode: colorCode ?? this.colorCode,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
    );
  }
}

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;

  const CartModel({
    required this.id,
    required this.userId,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return CartModel(
      id: json['_id'] as String,
      userId: json['user'] as String,
      items: itemsJson
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  double get subtotal {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }

  int get totalQuantity {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  int get itemCount {
    return items.length;
  }

  bool get isEmpty {
    return items.isEmpty;
  }
}
