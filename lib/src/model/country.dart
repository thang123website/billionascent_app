class Country {
  final String name;
  final String code;

  Country({required this.name, required this.code});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(name: json['name'], code: json['code']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'code': code};
  }
}
