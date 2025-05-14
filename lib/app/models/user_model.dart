class UserModel {
  final String id;
  final String email;
  final String? full_name;
  final String? phone;
  final String role; // 'shop_owner', 'customer', 'admin'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive; // Added this property

  UserModel({
    required this.id,
    required this.email,
    this.full_name,
    this.phone,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true, // Default value is true
  });

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      full_name: json['full_name'],
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      isActive: json['is_active'] ?? true, // Parse the isActive property
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': full_name,
      'phone': phone, // Fixed 'full_phone' typo to 'phone'
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive, // Include the isActive property in JSON
    };
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? email,
    String? full_name,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive, // Added to copyWith parameters
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      full_name: full_name ?? this.full_name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive, // Include in the copy
    );
  }
}