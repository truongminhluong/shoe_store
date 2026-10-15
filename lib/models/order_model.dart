import 'checkout_item_input_model.dart';

class OrderItemModel {
  final String productId;
  final String variantId;
  final int quantity;
  final double price;
  final String? productName;
  final String? productImage;
  final String? colorName;
  final String? colorCode;
  final int? size;

  const OrderItemModel({
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.price,
    this.productName,
    this.productImage,
    this.colorName,
    this.colorCode,
    this.size,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final variant = json['variant'];
    final productJson = product is Map<String, dynamic> ? product : null;
    final variantJson = variant is Map<String, dynamic> ? variant : null;

    return OrderItemModel(
      productId: _idValue(product),
      variantId: _idValue(variant),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      productName: productJson?['name']?.toString(),
      productImage: productJson?['image']?.toString(),
      colorName: variantJson?['colorName']?.toString(),
      colorCode: variantJson?['colorCode']?.toString(),
      size: (variantJson?['size'] as num?)?.toInt(),
    );
  }

  static String _idValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }
}

class OrderShippingAddressModel {
  final String fullName;
  final String phone;
  final String address;

  const OrderShippingAddressModel({
    required this.fullName,
    required this.phone,
    required this.address,
  });

  factory OrderShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderShippingAddressModel(
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String user;
  final List<OrderItemModel> items;
  final OrderShippingAddressModel shippingAddress;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String status;
  final String? voucher;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.user,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.transactionId,
    this.voucher,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final addressJson = json['shippingAddress'];
    final itemsJson = json['items'] as List<dynamic>? ?? const [];

    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      user: _idValue(json['user']),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList(),
      shippingAddress: OrderShippingAddressModel.fromJson(
        addressJson is Map<String, dynamic> ? addressJson : const {},
      ),
      subtotal: _doubleValue(json['subtotal']),
      shippingFee: _doubleValue(json['shippingFee']),
      tax: _doubleValue(json['tax']),
      discount: _doubleValue(json['discount']),
      total: _doubleValue(json['total']),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      transactionId: json['transactionId']?.toString(),
      status: json['status']?.toString() ?? '',
      voucher: json['voucher'] == null ? null : _idValue(json['voucher']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  static String _idValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  static double _doubleValue(dynamic value) =>
      value is num ? value.toDouble() : 0;
}

enum OrderPaymentMethod { cod, vnpay }

class CreateOrderRequest {
  final List<CheckoutItemInputModel> items;
  final String addressId;
  final String? voucherCode;
  final OrderPaymentMethod paymentMethod;

  const CreateOrderRequest({
    required this.items,
    required this.addressId,
    this.voucherCode,
    this.paymentMethod = OrderPaymentMethod.cod,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'addressId': addressId,
    if (voucherCode != null && voucherCode!.trim().isNotEmpty)
      'voucherCode': voucherCode!.trim(),
    'paymentMethod': paymentMethod.name,
  };
}
