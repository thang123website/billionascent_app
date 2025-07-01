class Address {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String address;
  final bool isDefault;
  final String? zipCode;

  Address({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.isDefault,
    this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      address: json['address'],
      isDefault: json['is_default'] == 1,
      zipCode: json['zip_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'is_default': isDefault,
      'zip_code': zipCode,
    };
  }
}
