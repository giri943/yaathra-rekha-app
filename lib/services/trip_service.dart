import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip.dart';
import '../models/contract.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';
import 'auth_service.dart';

class TripService {
  static const String baseUrl = 'https://yaathra-rekha-app.onrender.com/api';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getTrips({
    int page = 1, 
    int limit = 10,
    String? tripType,
    String? vehicleId,
    String? contractId,
    String? salaryPaid,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (tripType != null) queryParams['tripType'] = tripType;
      if (vehicleId != null) queryParams['vehicleId'] = vehicleId;
      if (contractId != null) queryParams['contractId'] = contractId;
      if (salaryPaid != null) queryParams['salaryPaid'] = salaryPaid;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      final uri = Uri.parse('$baseUrl/trips').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Trip> trips = (data['trips'] as List).map((json) {
          try {
            return Trip.fromJson(json);
          } catch (e) {
            print('Error parsing trip: $json, Error: $e');
            rethrow;
          }
        }).toList();
        
        return {
          'trips': trips,
          'contracts': (data['contracts'] as List).map((json) => Contract.fromJson(json)).toList(),
          'vehicles': (data['vehicles'] as List).map((json) => Vehicle.fromJson(json)).toList(),
          'drivers': (data['drivers'] as List).map((json) => Driver.fromJson(json)).toList(),
          'pagination': data['pagination']
        };
      } else {
        print('Failed to load trips: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load trips');
      }
    } catch (e) {
      print('Error in getTrips: $e');
      throw Exception('Error loading trips: $e');
    }
  }

  Future<Trip> addTrip(Trip trip) async {
    try {
      final headers = await _getHeaders();
      final tripData = trip.toJson();
      tripData.remove('userId'); // Remove userId, let backend set it from token
      
      final response = await http.post(
        Uri.parse('$baseUrl/trips'),
        headers: headers,
        body: json.encode(tripData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Trip.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to add trip: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Error adding trip: $e');
    }
  }

  Future<Trip> updateTrip(Trip trip) async {
    try {
      final headers = await _getHeaders();
      final tripData = trip.toJson();
      tripData.remove('userId'); // Remove userId, let backend set it from token
      
      final response = await http.put(
        Uri.parse('$baseUrl/trips/${trip.id}'),
        headers: headers,
        body: json.encode(tripData),
      );

      if (response.statusCode == 200) {
        return Trip.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update trip');
      }
    } catch (e) {
      throw Exception('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/trips/$tripId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete trip');
      }
    } catch (e) {
      throw Exception('Error deleting trip: $e');
    }
  }

  Future<Contract> getContractDetails(String contractId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trips/contract/$contractId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Contract.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load contract details');
      }
    } catch (e) {
      throw Exception('Error loading contract details: $e');
    }
  }

  // Calculate savari trip rate based on new pricing logic
  double calculateSavariRate(double distance, double fixedRateFor5Km, double perKmRate) {
    if (distance <= 5.0) {
      return fixedRateFor5Km;
    } else {
      final additionalKm = distance - 5.0;
      return fixedRateFor5Km + (additionalKm * perKmRate);
    }
  }

  // Calculate driver salary (25% of trip rate by default)
  double calculateDriverSalary(double tripRate, {double percentage = 0.25}) {
    return tripRate * percentage;
  }
}