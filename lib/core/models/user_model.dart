class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime? createdAt;
  final List<String>? permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.createdAt,
    this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String>? perms;
    if (json['permissions'] != null) {
      perms = List<String>.from(json['permissions']);
    } else if (json['roles'] != null) {
      final roles = json['roles'];
      if (roles is List) {
        perms = List<String>.from(roles);
      }
    }

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      permissions: perms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
      'permissions': permissions,
    };
  }

  bool hasPermission(String permission) {
    return permissions?.contains(permission) ?? false;
  }
}
