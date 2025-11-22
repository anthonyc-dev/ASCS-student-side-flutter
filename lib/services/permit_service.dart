import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PermitService {
  final String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

  /// Fetch the permit details including QR code for a student
  Future<Map<String, dynamic>?> getPermitByStudentId(String studentId) async {
    try {
      final url = Uri.parse("$apiUrl/permit/student/$studentId");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // ignore: avoid_print
        print('Failed to fetch permit: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error fetching permit: $error');
      return null;
    }
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
