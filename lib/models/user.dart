class User {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? phone;
  final String role;
  final String? status;
  final String? businessId;
  final String? hotelId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
    this.status,
    this.businessId,
    this.hotelId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      phone: json['phone'],
      role: json['role'] ?? '',
      status: json['status'],
      businessId: json['businessId'],
      hotelId: json['hotelId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'status': status,
      'businessId': businessId,
      'hotelId': hotelId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    String? status,
    String? businessId,
    String? hotelId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      businessId: businessId ?? this.businessId,
      hotelId: hotelId ?? this.hotelId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

