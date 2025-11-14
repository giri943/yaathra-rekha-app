import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';
import 'report_service_web.dart' if (dart.library.io) 'report_service_mobile.dart' as platform;

class ReportService {
  final AuthService _authService = AuthService();

  Future<Uint8List> generateContractBillingPDF(
    String contractId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      // Build URL with query parameters
      String url = '${AppConfig.apiBaseUrl}/reports/contract-billing/$contractId';
      
      if (startDate != null && endDate != null) {
        url += '?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to generate PDF');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadPDF(Uint8List pdfBytes, String filename) async {
    await platform.downloadPDF(pdfBytes, filename);
  }
}
