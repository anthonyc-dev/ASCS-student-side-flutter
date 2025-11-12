import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/student.dart';

class StudentProfileService {
  String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

  /// Fetches student data by school ID
  Future<Student> getStudentBySchoolId(String schoolId) async {
    try {
      var url = Uri.parse("$apiUrl/student/getStudentBySchoolId/$schoolId");

      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Student.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Student not found');
      } else {
        throw Exception('Failed to load student data');
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from the server.');
    } catch (error) {
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }

  /// Updates student data by student ID
  Future<Student> updateStudent(String studentId, Map<String, dynamic> updates) async {
    try {
      var url = Uri.parse("$apiUrl/student/updateStudent/$studentId");

      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Student.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Student not found');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid data provided');
      } else {
        throw Exception('Failed to update student data');
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
