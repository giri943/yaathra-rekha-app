import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../config/app_config.dart';

class VehicleService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: headers,
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode == 201) {
        return Vehicle.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add vehicle');
      }
    } catch (e) {
      throw Exception('Error adding vehicle: $e');
    }
  }

  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/vehicles/${vehicle.id}'),
        headers: headers,
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode == 200) {
        return Vehicle.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update vehicle');
      }
    } catch (e) {
      throw Exception('Error updating vehicle: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/vehicles/$vehicleId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }
}