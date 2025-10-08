import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/widgets/show_modal.dart';

class Authentication {
  String apiUrl = dotenv.env['API_URL'] ?? "Default URL";

  //log in
  Future<String> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var url = Uri.parse("$apiUrl/login");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (!context.mounted) return '';
        DialogUtil.showSuccessDialog(
          context,
          data["message"] ?? "Login successful!",
        );

        return data["message"] ?? "Login successful!";
      } else {
        var errorData = jsonDecode(response.body);
        if (kDebugMode) {
          print(errorData["error"]);
        }
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

  //sign up
  Future<String> signUp({
    required BuildContext context,
    required String studentId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      var url = Uri.parse("$apiUrl/register");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "studentId": studentId,
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phoneNumber": phoneNumber,
          "password": password,
          "role": "student",
        }),
      );

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);

        if (!context.mounted) return '';
        Navigator.pushReplacementNamed(context, "/signin");
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
