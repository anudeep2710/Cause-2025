class ApiUser {
  final String id;
  final String name;
  final String? profileImage;

  ApiUser({
    required this.id,
    required this.name,
    this.profileImage,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
    };
  }
}
