import 'checkout_item_input_model.dart';

class VoucherModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final double minOrderValue;
  final double maxDiscount;
  final int quantity;
  final int usedCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.quantity,
    required this.usedCount,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? '',
      discountValue: _doubleValue(json['discountValue']),
      minOrderValue: _doubleValue(json['minOrderValue']),
      maxDiscount: _doubleValue(json['maxDiscount']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
    );
  }

  static double _doubleValue(dynamic value) =>
      value is num ? value.toDouble() : 0;
}

/// The current backend validate response contains `voucher` and `discount`.
class VoucherValidationModel {
  final VoucherModel voucher;
  final double discount;

  const VoucherValidationModel({required this.voucher, required this.discount});

  factory VoucherValidationModel.fromJson(Map<String, dynamic> json) {
    final voucherJson = json['voucher'];
    if (voucherJson is! Map<String, dynamic>) {
      throw const FormatException('Dữ liệu voucher không hợp lệ');
    }

    final discount = json['discount'];
    if (discount is! num) {
      throw const FormatException('Dữ liệu giảm giá không hợp lệ');
    }

    return VoucherValidationModel(
      voucher: VoucherModel.fromJson(voucherJson),
      discount: discount.toDouble(),
    );
  }
}

class VoucherValidationRequest {
  final String code;
  final List<CheckoutItemInputModel> items;

  const VoucherValidationRequest({required this.code, required this.items});

  Map<String, dynamic> toJson() => {
    'code': code.trim(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}
