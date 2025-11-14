import 'vehicle.dart';

class Contract {
  final String id;
  final String contractName;
  final double rate;
  final String vehicleId;
  final double averageDistance;
  final DateTime contractEndDate;
  final String? contactPhone;
  final String userId;
  final DateTime createdAt;
  final Vehicle? vehicle; // Populated vehicle data

  Contract({
    required this.id,
    required this.contractName,
    required this.rate,
    required this.vehicleId,
    required this.averageDistance,
    required this.contractEndDate,
    this.contactPhone,
    required this.userId,
    required this.createdAt,
    this.vehicle,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractName': contractName,
      'rate': rate,
      'vehicleId': vehicleId,
      'averageDistance': averageDistance,
      'contractEndDate': contractEndDate.toIso8601String(),
      'contactPhone': contactPhone,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contract.fromJson(Map<String, dynamic> json) {
    // Safely extract vehicleId
    String vehicleIdStr = '';
    Vehicle? vehicleObj;
    
    final vehicleData = json['vehicleId'];
    if (vehicleData is String) {
      vehicleIdStr = vehicleData;
    } else if (vehicleData is Map<String, dynamic>) {
      vehicleIdStr = vehicleData['_id']?.toString() ?? '';
      try {
        vehicleObj = Vehicle.fromJson(vehicleData);
      } catch (e) {
        // Silently handle vehicle parsing error
      }
    }
    
    return Contract(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      contractName: json['contractName']?.toString() ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      vehicleId: vehicleIdStr,
      averageDistance: (json['averageDistance'] as num?)?.toDouble() ?? 0.0,
      contractEndDate: DateTime.tryParse(json['contractEndDate']?.toString() ?? '') ?? DateTime.now(),
      contactPhone: json['contactPhone']?.toString(),
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      vehicle: vehicleObj,
    );
  }
}