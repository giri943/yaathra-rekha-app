import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contract.dart';
import '../models/vehicle.dart';
import '../config/app_config.dart';

class ContractService {
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

  Future<Map<String, dynamic>> getContractsPageData({int page = 1, int limit = 10, String? vehicleId, String? status}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (vehicleId != null) queryParams['vehicleId'] = vehicleId;
      if (status != null) queryParams['status'] = status;
      
      final uri = Uri.parse('$baseUrl/contracts').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Contract> contracts = (data['contracts'] as List).map((json) => Contract.fromJson(json)).toList();
        final List<Vehicle> vehicles = (data['vehicles'] as List).map((json) => Vehicle.fromJson(json)).toList();
        
        return {
          'contracts': contracts,
          'vehicles': vehicles,
          'pagination': data['pagination']
        };
      } else {
        throw Exception('Failed to load contracts page data');
      }
    } catch (e) {
      throw Exception('Error fetching contracts page data: $e');
    }
  }
  
  Future<List<Contract>> getAllContracts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contracts?limit=1000'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['contracts'] as List).map((json) => Contract.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load contracts');
      }
    } catch (e) {
      throw Exception('Error fetching contracts: $e');
    }
  }
  
  Future<List<Contract>> getActiveContracts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contracts?limit=1000&active=true'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final contracts = (data['contracts'] as List).map((json) => Contract.fromJson(json)).toList();
        // Filter on client side as well to ensure no expired contracts
        final now = DateTime.now();
        return contracts.where((contract) => contract.contractEndDate.isAfter(now)).toList();
      } else {
        throw Exception('Failed to load active contracts');
      }
    } catch (e) {
      throw Exception('Error fetching active contracts: $e');
    }
  }

  Future<Contract> addContract(Contract contract) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/contracts'),
        headers: headers,
        body: json.encode(contract.toJson()),
      );

      if (response.statusCode == 201) {
        return Contract.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add contract');
      }
    } catch (e) {
      throw Exception('Error adding contract: $e');
    }
  }

  Future<Contract> updateContract(Contract contract) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/contracts/${contract.id}'),
        headers: headers,
        body: json.encode(contract.toJson()),
      );

      if (response.statusCode == 200) {
        return Contract.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update contract');
      }
    } catch (e) {
      throw Exception('Error updating contract: $e');
    }
  }

  Future<void> deleteContract(String contractId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/contracts/$contractId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete contract');
      }
    } catch (e) {
      throw Exception('Error deleting contract: $e');
    }
  }
}