class Vehicle {
  final String id;
  final String model;
  final String manufacturer;
  final DateTime insuranceExpiry;
  final DateTime taxDate;
  final DateTime testDate;
  final DateTime pollutionDate;
  final String userId;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.model,
    required this.manufacturer,
    required this.insuranceExpiry,
    required this.taxDate,
    required this.testDate,
    required this.pollutionDate,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'manufacturer': manufacturer,
      'insuranceExpiry': insuranceExpiry.toIso8601String(),
      'taxDate': taxDate.toIso8601String(),
      'testDate': testDate.toIso8601String(),
      'pollutionDate': pollutionDate.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? json['id'] ?? '',
      model: json['model'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      insuranceExpiry: DateTime.parse(json['insuranceExpiry']),
      taxDate: DateTime.parse(json['taxDate']),
      testDate: DateTime.parse(json['testDate']),
      pollutionDate: DateTime.parse(json['pollutionDate']),
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}