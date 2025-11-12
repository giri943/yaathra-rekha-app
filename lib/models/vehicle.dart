class Vehicle {
  final String id;
  final String vehicleNumber;
  final String model;
  final String manufacturer;
  final DateTime insuranceExpiry;
  final DateTime taxDate;
  final DateTime testDate;
  final DateTime pollutionDate;
  final String userId;
  final DateTime createdAt;
  final double fixedRateFor5Km;
  final double perKmRate;

  Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.model,
    required this.manufacturer,
    required this.insuranceExpiry,
    required this.taxDate,
    required this.testDate,
    required this.pollutionDate,
    required this.userId,
    required this.createdAt,
    required this.fixedRateFor5Km,
    required this.perKmRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'model': model,
      'manufacturer': manufacturer,
      'insuranceExpiry': insuranceExpiry.toIso8601String(),
      'taxDate': taxDate.toIso8601String(),
      'testDate': testDate.toIso8601String(),
      'pollutionDate': pollutionDate.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'fixedRateFor5Km': fixedRateFor5Km,
      'perKmRate': perKmRate,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? '',
      insuranceExpiry: DateTime.tryParse(json['insuranceExpiry']?.toString() ?? '') ?? DateTime.now(),
      taxDate: DateTime.tryParse(json['taxDate']?.toString() ?? '') ?? DateTime.now(),
      testDate: DateTime.tryParse(json['testDate']?.toString() ?? '') ?? DateTime.now(),
      pollutionDate: DateTime.tryParse(json['pollutionDate']?.toString() ?? '') ?? DateTime.now(),
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      fixedRateFor5Km: (json['fixedRateFor5Km'] as num?)?.toDouble() ?? 0.0,
      perKmRate: (json['perKmRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}