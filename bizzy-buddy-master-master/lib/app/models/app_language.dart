class AppLanguage {
  final String code;
  final String name;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
    };
  }

  @override
  String toString() => name;
}
