// user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String password;
  final String phone;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.password,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'password': password, // ⚠️ مازلت بترفع الباسورد زي ما طلبت
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      password: map['password'] ?? '',
      createdAt: DateTime.tryParse(map["createdAt"] ?? '') ?? DateTime.now(),
      phone: map['phone'] ?? '',
    );
  }
}
