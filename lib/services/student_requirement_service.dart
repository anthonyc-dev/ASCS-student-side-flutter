import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/student_requirement.dart';

class StudentRequirementService {
  String apiUrl = dotenv.env['API_URL'] ?? "Default URL";

  Future<List<StudentRequirement>> getStudentRequirementsBySchoolId(
      String schoolId) async {
    try {
      var url = Uri.parse(
          "$apiUrl/studentReq/getStudentRequirementsBySchoolId/$schoolId");

      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StudentRequirement.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load student requirements');
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from the server.');
    } catch (error) {
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }

  Future<List<StudentInstitutionalRequirement>>
      getStudentInstitutionalRequirementsByStudentId(String studentId) async {
    try {
      var url = Uri.parse(
          "$apiUrl/institutionalReq/getStudentRequirementsByStudentId/$studentId");

      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => StudentInstitutionalRequirement.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load institutional requirements');
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
