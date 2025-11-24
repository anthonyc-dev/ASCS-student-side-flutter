import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/student_requirement.dart';
import 'package:my_app/services/offline_storage_service.dart';
import 'package:my_app/services/network_service.dart';

class StudentRequirementService {
  String apiUrl = dotenv.env['API_URL'] ?? "Default URL";
  final NetworkService _networkService = NetworkService();

  Future<List<StudentRequirement>> getStudentRequirementsBySchoolId(
      String schoolId) async {
    final isOnline = await _networkService.checkConnectivity();

    // Try to fetch from API if online
    if (isOnline) {
      try {
        var url = Uri.parse(
            "$apiUrl/studentReq/getStudentRequirementsBySchoolId/$schoolId");

        var response = await http.get(
          url,
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          final requirements =
              data.map((json) => StudentRequirement.fromJson(json)).toList();

          // Cache the data for offline use
          final requirementsJson = requirements.map((r) => r.toJson()).toList();
          await OfflineStorageService.saveDepartmentRequirements(
              schoolId, requirementsJson);

          return requirements;
        } else {
          throw Exception('Failed to load student requirements');
        }
      } on http.ClientException {
        // Fall through to offline mode
      } on FormatException {
        // Fall through to offline mode
      } catch (error) {
        // Fall through to offline mode
      }
    }

    // Offline mode - load from cache
    final cachedData =
        OfflineStorageService.getDepartmentRequirements(schoolId);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return cachedData
            .map((json) => StudentRequirement.fromJson(json))
            .toList();
      } catch (e) {
        // If cache parsing fails, return empty list instead of throwing
        return [];
      }
    }

    // Return empty list when offline and no cache (don't throw error)
    return [];
  }

  Future<List<StudentInstitutionalRequirement>>
      getStudentInstitutionalRequirementsByStudentId(String studentId) async {
    final isOnline = await _networkService.checkConnectivity();

    // Try to fetch from API if online
    if (isOnline) {
      try {
        var url = Uri.parse(
            "$apiUrl/institutionalReq/getStudentRequirementsByStudentId/$studentId");

        var response = await http.get(
          url,
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          final requirements = data
              .map((json) => StudentInstitutionalRequirement.fromJson(json))
              .toList();

          // Cache the data for offline use
          final requirementsJson = requirements.map((r) => r.toJson()).toList();
          await OfflineStorageService.saveInstitutionalRequirements(
              studentId, requirementsJson);

          return requirements;
        } else {
          throw Exception('Failed to load institutional requirements');
        }
      } on http.ClientException {
        // Fall through to offline mode
      } on FormatException {
        // Fall through to offline mode
      } catch (error) {
        // Fall through to offline mode
      }
    }

    // Offline mode - load from cache
    final cachedData =
        OfflineStorageService.getInstitutionalRequirements(studentId);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        return cachedData
            .map((json) => StudentInstitutionalRequirement.fromJson(json))
            .toList();
      } catch (e) {
        // If cache parsing fails, return empty list instead of throwing
        return [];
      }
    }

    // Return empty list when offline and no cache (don't throw error)
    return [];
  }
}
