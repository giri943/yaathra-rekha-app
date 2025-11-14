import 'contract.dart';
import 'vehicle.dart';

class Trip {
  final String id;
  final String tripType; // 'contract' or 'savari'
  final String? contractId;
  final String vehicleId;
  final String clientName;
  final String? clientMobile;
  final String driverName;
  final double driverSalary;
  final bool driverSalaryPaid;
  final bool isDriverSalaryManual;
  final double tripRate;
  final double? startKm;
  final double? endKm;
  final double? distance;
  final double? fixedRateUsed;
  final double? perKmRateUsed;
  final double? additionalKm;
  final double ownerTakeHome;
  final DateTime tripDate;
  final String? notes;
  final String userId;
  final DateTime createdAt;

  // Populated fields
  final Contract? contract;
  final Vehicle? vehicle;

  Trip({
    required this.id,
    required this.tripType,
    this.contractId,
    required this.vehicleId,
    required this.clientName,
    this.clientMobile,
    required this.driverName,
    required this.driverSalary,
    required this.driverSalaryPaid,
    required this.isDriverSalaryManual,
    required this.tripRate,
    this.startKm,
    this.endKm,
    this.distance,
    this.fixedRateUsed,
    this.perKmRateUsed,
    this.additionalKm,
    required this.ownerTakeHome,
    required this.tripDate,
    this.notes,
    required this.userId,
    required this.createdAt,
    this.contract,
    this.vehicle,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    try {
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
      
      // Safely extract contractId
      String? contractIdStr;
      Contract? contractObj;
      
      if (json.containsKey('contractId') && json['contractId'] != null) {
        final contractData = json['contractId'];
        if (contractData is String) {
          contractIdStr = contractData;
        } else if (contractData is Map<String, dynamic>) {
          contractIdStr = contractData['_id']?.toString();
          try {
            contractObj = Contract.fromJson(contractData);
          } catch (e) {
            // Silently handle contract parsing error
          }
        }
      }
      
      return Trip(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        tripType: json['tripType']?.toString() ?? '',
        contractId: contractIdStr,
        vehicleId: vehicleIdStr,
        clientName: json['clientName']?.toString() ?? '',
        clientMobile: json['clientMobile']?.toString(),
        driverName: json['driverName']?.toString() ?? '',
        driverSalary: double.tryParse(json['driverSalary']?.toString() ?? '0') ?? 0.0,
        driverSalaryPaid: json['driverSalaryPaid'] == true,
        isDriverSalaryManual: json['isDriverSalaryManual'] == true,
        tripRate: double.tryParse(json['tripRate']?.toString() ?? '0') ?? 0.0,
        startKm: double.tryParse(json['startKm']?.toString() ?? ''),
        endKm: double.tryParse(json['endKm']?.toString() ?? ''),
        distance: double.tryParse(json['distance']?.toString() ?? ''),
        fixedRateUsed: double.tryParse(json['fixedRateUsed']?.toString() ?? ''),
        perKmRateUsed: double.tryParse(json['perKmRateUsed']?.toString() ?? ''),
        additionalKm: double.tryParse(json['additionalKm']?.toString() ?? ''),
        ownerTakeHome: double.tryParse(json['ownerTakeHome']?.toString() ?? '0') ?? 0.0,
        tripDate: DateTime.tryParse(json['tripDate']?.toString() ?? '') ?? DateTime.now(),
        notes: json['notes']?.toString(),
        userId: json['userId']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        contract: contractObj,
        vehicle: vehicleObj,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'tripType': tripType,
      'vehicleId': vehicleId,
      'clientName': clientName,
      'driverName': driverName,
      'driverSalary': driverSalary,
      'driverSalaryPaid': driverSalaryPaid,
      'isDriverSalaryManual': isDriverSalaryManual,
      'tripRate': tripRate,
      'ownerTakeHome': ownerTakeHome,
      'tripDate': tripDate.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
    
    // Only include contractId if it's not null
    final contractIdValue = contractId;
    if (contractIdValue != null) {
      json['contractId'] = contractIdValue;
    }
    
    // Only include savari-specific fields if they're not null
    final startKmValue = startKm;
    if (startKmValue != null) json['startKm'] = startKmValue;
    
    final endKmValue = endKm;
    if (endKmValue != null) json['endKm'] = endKmValue;
    
    final distanceValue = distance;
    if (distanceValue != null) json['distance'] = distanceValue;
    
    final fixedRateUsedValue = fixedRateUsed;
    if (fixedRateUsedValue != null) json['fixedRateUsed'] = fixedRateUsedValue;
    
    final perKmRateUsedValue = perKmRateUsed;
    if (perKmRateUsedValue != null) json['perKmRateUsed'] = perKmRateUsedValue;
    
    final additionalKmValue = additionalKm;
    if (additionalKmValue != null) json['additionalKm'] = additionalKmValue;
    
    final notesValue = notes;
    if (notesValue != null) json['notes'] = notesValue;
    
    final clientMobileValue = clientMobile;
    if (clientMobileValue != null) json['clientMobile'] = clientMobileValue;
    
    return json;
  }
}