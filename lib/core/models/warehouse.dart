class Warehouse {
  final int id;
  final String name;
  final String? code;
  final String? address;
  final String? phone;
  final bool isActive;

  Warehouse({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.phone,
    this.isActive = true,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'phone': phone,
      'is_active': isActive,
    };
  }

  @override
  String toString() => name;
}