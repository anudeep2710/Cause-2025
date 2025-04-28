class ApiUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ApiUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return ApiUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
