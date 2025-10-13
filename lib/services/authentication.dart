import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/widgets/show_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  String apiUrl = dotenv.env['API_URL'] ?? "Default URL";

  //log in
  Future<String> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var url = Uri.parse("$apiUrl/loginStudent");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var student =
            data["student"]; // ← assuming your API returns this structure

        // Save user info to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("firstName", student["firstName"]);
        await prefs.setString("userSchoolId", student["schoolId"]);

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
      var url = Uri.parse("$apiUrl/registerStudent");

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
}
