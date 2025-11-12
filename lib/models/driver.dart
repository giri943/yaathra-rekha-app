class Driver {
  final String id;
  final String name;
  final String phone;
  final String userId;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
