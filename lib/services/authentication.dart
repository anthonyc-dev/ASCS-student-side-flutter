import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/widgets/show_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/services/offline_storage_service.dart';
import 'package:my_app/services/network_service.dart';

class Authentication {
  String apiUrl = dotenv.env['API_URL'] ?? "Default URL";
  final NetworkService _networkService = NetworkService();

  //log in
  Future<String> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // Check if offline
    final isOnline = await _networkService.checkConnectivity();

    if (!isOnline) {
      // Try offline login - check if credentials match cached data
      final cachedEmail = OfflineStorageService.getEmail();
      final cachedSchoolId = OfflineStorageService.getSchoolId();

      if (cachedEmail == email && OfflineStorageService.isLoggedInOffline()) {
        // Restore SharedPreferences for compatibility
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            "firstName", OfflineStorageService.getFirstName() ?? '');
        await prefs.setString("userSchoolId", cachedSchoolId ?? '');

        if (!context.mounted) return '';
        DialogUtil.showSuccessDialog(
          context,
          "Login successful! (Offline Mode)",
        );
        return "Success";
      } else {
        return "Cannot login offline. Please check your internet connection.";
      }
    }

    // Online login
    try {
      var url = Uri.parse("$apiUrl/student/loginStudent");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var student =
            data["student"]; // ← assuming your API returns this structure

        // Save user info to SharedPreferences (for compatibility)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("firstName", student["firstName"]);
        await prefs.setString("userSchoolId", student["schoolId"]);

        // Save to Hive for offline access
        await OfflineStorageService.saveAuthData(
          email: email,
          firstName: student["firstName"],
          schoolId: student["schoolId"],
          userId: student["id"] ?? student["_id"],
          accessToken: data["accessToken"],
          refreshToken: data["refreshToken"],
        );

        if (!context.mounted) return '';
        DialogUtil.showSuccessDialog(
          context,
          data["message"] ?? "Login successful!",
        );

        return "Success";
      } else {
        var errorData = jsonDecode(response.body);
        return errorData["error"] ?? "Failed to log in. Please try again.";
      }
    } on http.ClientException {
      // Network error - try offline login
      final cachedEmail = OfflineStorageService.getEmail();
      if (cachedEmail == email && OfflineStorageService.isLoggedInOffline()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            "firstName", OfflineStorageService.getFirstName() ?? '');
        await prefs.setString(
            "userSchoolId", OfflineStorageService.getSchoolId() ?? '');

        if (!context.mounted) return '';
        DialogUtil.showSuccessDialog(
          context,
          "Login successful! (Offline Mode)",
        );
        return "Success";
      }
      return "Network error. Please check your internet connection.";
    } on FormatException {
      return "Invalid response format from the server.";
    } catch (error) {
      return "Unexpected error: ${error.toString()}";
    }
  }

  //sign up
  Future<String> signUp({
    required BuildContext context,
    required String schoolId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String program,
    required String yearLevel,
    required String password,
  }) async {
    try {
      var url = Uri.parse("$apiUrl/student/registerStudent");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "schoolId": schoolId,
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phoneNumber": phoneNumber,
          "program": program,
          "yearLevel": yearLevel,
          "password": password,
        }),
      );

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);

        if (!context.mounted) return '';
        Navigator.pushReplacementNamed(context, "/login");
        return data["message"] ?? "Registration successful!";
      } else if (response.statusCode == 404) {
        var errorData = jsonDecode(response.body);
        return errorData["error"] ?? "Student ID not Found";
      } else {
        var errorData = jsonDecode(response.body);
        return errorData["error"] ?? "Failed to sign up. Please try again.";
      }
    } on http.ClientException {
      return "Network error. Please check your internet connection.";
    } on FormatException {
      return "Invalid response format from the server.";
    } catch (error) {
      return "Unexpected error: ${error.toString()}";
    }
  }

  //logout
  Future<String> logout({
    required BuildContext context,
  }) async {
    try {
      var url = Uri.parse("$apiUrl/student/logoutStudent");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Clear user info from local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Clear Hive offline data
        await OfflineStorageService.clearAuthData();

        if (!context.mounted) return '';

        // Navigate to login screen
        Navigator.pushReplacementNamed(context, "/login");

        return data["message"] ?? "Logout successful!";
      } else {
        var errorData = jsonDecode(response.body);
        return errorData["error"] ?? "Failed to log out. Please try again.";
      }
    } on http.ClientException {
      // Even if network fails, clear local data for logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await OfflineStorageService.clearAuthData();

      if (!context.mounted) return '';
      Navigator.pushReplacementNamed(context, "/login");
      return "Logged out (offline)";
    } on FormatException {
      return "Invalid response format from the server.";
    } catch (error) {
      return "Unexpected error: ${error.toString()}";
    }
  }

  //change password
  Future<String> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      var url = Uri.parse("$apiUrl/student/changeStudentPassword");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["message"] ?? "Password changed successfully!";
      } else {
        var errorData = jsonDecode(response.body);
        return errorData["error"] ??
            "Failed to change password. Please try again.";
      }
    } on http.ClientException {
      return "Network error. Please check your internet connection.";
    } on FormatException {
      return "Invalid response format from the server.";
    } catch (error) {
      return "Unexpected error: ${error.toString()}";
    }
  }
}
