class BrandModel {
  final String id;
  final String name;
  final String logo;

  const BrandModel({required this.id, required this.name, required this.logo});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}
