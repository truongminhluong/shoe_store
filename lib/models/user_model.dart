class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatar;
  final String role;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
