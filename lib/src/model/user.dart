class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? dob;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;
  final String? accountType;
  final String? companyName;
  final String? businessTaxCode;
  final String? businessAddress;
  final String? industry;
  final String? registrantAddress;
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.dob,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.accountType,
    this.companyName,
    this.businessTaxCode,
    this.businessAddress,
    this.industry,
    this.registrantAddress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      dob: json['dob'],
      avatar: json['avatar'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      accountType: json['account_type'],
      companyName: json['company_name'],
      businessTaxCode: json['business_tax_code'],
      businessAddress: json['business_address'],
      industry: json['industry'],
      registrantAddress: json['registrant_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'avatar': avatar,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'account_type': accountType,
      'company_name': companyName,
      'business_tax_code': businessTaxCode,
      'business_address': businessAddress,
      'industry': industry,
      'registrant_address': registrantAddress,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phone: $phone}';
  }
}
