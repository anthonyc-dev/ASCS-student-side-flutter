import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/clearance.dart';

class ClearanceService {
  String apiUrl = dotenv.env['API_URL'] ?? "Default URL";

  Future<Clearance?> getCurrentClearance() async {
    try {
      var url = Uri.parse("$apiUrl/clearance/current");

      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Clearance.fromJson(data);
      } else {
        throw Exception('Failed to load current clearance');
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from the server.');
    } catch (error) {
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }
}
