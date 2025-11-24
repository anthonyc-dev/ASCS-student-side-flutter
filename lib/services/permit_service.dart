import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/services/offline_storage_service.dart';
import 'package:my_app/services/network_service.dart';

class PermitService {
  final String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";
  final NetworkService _networkService = NetworkService();

  /// Fetch the permit details including QR code for a student
  Future<Map<String, dynamic>?> getPermitByStudentId(String studentId) async {
    final isOnline = await _networkService.checkConnectivity();

    // Try to fetch from API if online
    if (isOnline) {
      try {
        final url = Uri.parse("$apiUrl/permit/student/$studentId");

        final response = await http.get(
          url,
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Cache the data for offline use
          await OfflineStorageService.savePermitData(studentId, data);

          return data;
        } else {
          // ignore: avoid_print
          print('Failed to fetch permit: ${response.statusCode}');
          // Fall through to offline mode
        }
      } catch (error) {
        // ignore: avoid_print
        print('Error fetching permit: $error');
        // Fall through to offline mode
      }
    }

    // Offline mode - load from cache
    final cachedData = OfflineStorageService.getPermitData(studentId);
    if (cachedData != null) {
      return cachedData;
    }

    return null;
  }

  /// Generate QR code for a student (if you need to trigger generation from app)
  Future<Map<String, dynamic>?> generateQRCode({
    required String cashierId,
    required String studentId,
  }) async {
    try {
      final url = Uri.parse("$apiUrl/permit/generate/$cashierId");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"studentId": studentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // ignore: avoid_print
        print('Failed to generate QR: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error generating QR: $error');
      return null;
    }
  }
}
