import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';
import '../config/app_config.dart';

class DriverService {
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

  Future<List<Driver>> getAllDrivers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/drivers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      throw Exception('Error fetching drivers: $e');
    }
  }

  Future<Driver> addDriver(Driver driver) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/drivers'),
        headers: headers,
        body: json.encode(driver.toJson()),
      );

      if (response.statusCode == 201) {
        return Driver.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add driver');
      }
    } catch (e) {
      throw Exception('Error adding driver: $e');
    }
  }

  Future<Driver> updateDriver(Driver driver) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/drivers/${driver.id}'),
        headers: headers,
        body: json.encode(driver.toJson()),
      );

      if (response.statusCode == 200) {
        return Driver.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update driver');
      }
    } catch (e) {
      throw Exception('Error updating driver: $e');
    }
  }

  Future<void> deleteDriver(String driverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/drivers/$driverId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete driver');
      }
    } catch (e) {
      throw Exception('Error deleting driver: $e');
    }
  }
}
