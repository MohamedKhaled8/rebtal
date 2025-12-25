// user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String password;
  final String phone;
  final DateTime createdAt;

  // Admin payment info (only for admin role)
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? vodafoneCashNumber;
  final String? instaPayNumber;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.password,
    required this.phone,
    required this.createdAt,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.vodafoneCashNumber,
    this.instaPayNumber,
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
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'vodafoneCashNumber': vodafoneCashNumber,
      'instaPayNumber': instaPayNumber,
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
      bankName: map['bankName'],
      bankAccountNumber: map['bankAccountNumber'],
      bankAccountName: map['bankAccountName'],
      vodafoneCashNumber: map['vodafoneCashNumber'],
      instaPayNumber: map['instaPayNumber'],
    );
  }
}
