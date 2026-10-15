class AddressModel {
  final String id;
  final String user;
  final String fullName;
  final String phone;
  final String addressDetail;
  final String ward;
  final String district;
  final String province;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.user,
    required this.fullName,
    required this.phone,
    required this.addressDetail,
    required this.ward,
    required this.district,
    required this.province,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      user: _idValue(json['user']),
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressDetail: json['addressDetail']?.toString() ?? '',
      ward: json['ward']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  static String _idValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }
}

/// Allowlisted fields accepted by the Address create and partial update APIs.
class AddressInput {
  final String? fullName;
  final String? phone;
  final String? addressDetail;
  final String? ward;
  final String? district;
  final String? province;
  final bool? isDefault;

  const AddressInput({
    this.fullName,
    this.phone,
    this.addressDetail,
    this.ward,
    this.district,
    this.province,
    this.isDefault,
  });

  Map<String, dynamic> toJson() => {
    if (fullName != null) 'fullName': fullName,
    if (phone != null) 'phone': phone,
    if (addressDetail != null) 'addressDetail': addressDetail,
    if (ward != null) 'ward': ward,
    if (district != null) 'district': district,
    if (province != null) 'province': province,
    if (isDefault != null) 'isDefault': isDefault,
  };
}
