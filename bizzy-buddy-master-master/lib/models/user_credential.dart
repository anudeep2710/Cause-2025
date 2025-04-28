class UserCredential {
  final String name;
  final String email;
  final String password;

  UserCredential({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory UserCredential.fromJson(Map<String, dynamic> json) {
    return UserCredential(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}
