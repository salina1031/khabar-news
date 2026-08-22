// UserModel - represents an app user (resident or admin).
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String ward;
  final String role; // 'user' or 'admin'
  final bool isPremium;
  final String fcmToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.ward = '',
    this.role = 'user',
    this.isPremium = false,
    this.fcmToken = '',
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      ward: map['ward'] ?? '',
      role: map['role'] ?? 'user',
      isPremium: map['isPremium'] ?? false,
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'ward': ward,
      'role': role,
      'isPremium': isPremium,
      'fcmToken': fcmToken,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
