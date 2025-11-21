import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// Updates student data by database ID
  Future<Student> updateStudent(
      String studentId, Map<String, dynamic> updates) async {
    try {
      var url = Uri.parse("$apiUrl/student/updateStudent/$studentId");

      if (kDebugMode) {
        print('updateStudent - URL: $url');
        print('updateStudent - Body: ${jsonEncode(updates)}');
      }

      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updates),
      );

      if (kDebugMode) {
        print('updateStudent - Response status: ${response.statusCode}');
        print('updateStudent - Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Student.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Student not found');
      } else if (response.statusCode == 400) {
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Invalid data provided');
        } catch (e) {
          throw Exception('Invalid data provided');
        }
      } else if (response.statusCode == 500) {
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Server error';
          if (errorData['error'] != null) {
            errorMsg += ' - ${errorData['error']['name'] ?? 'Unknown error'}';
          }
          throw Exception(errorMsg);
        } catch (e) {
          throw Exception('Server error occurred. Please try again later.');
        }
      } else {
        throw Exception(
            'Failed to update student data. Status: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from the server.');
    } catch (error) {
      if (kDebugMode) print('updateStudent error: $error');
      if (error.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }

  /// Uploads profile image using updateStudentProfileImage endpoint
  Future<Student> uploadProfileImage(
      String schoolId, File imageFile, Student currentStudent) async {
    try {
      final cleanSchoolId = schoolId.trim();
      var url =
          Uri.parse("$apiUrl/student/updateStudentProfileImage/$cleanSchoolId");

      if (kDebugMode) {
        print('==========================================');
        print('uploadProfileImage - Starting upload');
        print('uploadProfileImage - schoolId: $cleanSchoolId');
        print('uploadProfileImage - URL: $url');
        print('uploadProfileImage - File path: ${imageFile.path}');
        print('uploadProfileImage - File exists: ${await imageFile.exists()}');
        print(
            'uploadProfileImage - File size: ${await imageFile.length()} bytes');
        print('==========================================');
      }

      // Verify file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Get file size and create stream
      final fileLength = await imageFile.length();
      final fileStream = imageFile.openRead();
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      if (kDebugMode) {
        print('uploadProfileImage - File size: $fileLength bytes');
        print('uploadProfileImage - File name: $fileName');
      }

      // Create multipart request with PUT method
      var request = http.MultipartRequest('PUT', url);

      // Add headers - multipart/form-data boundary is automatically set by http package
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Create multipart file using stream (more reliable than fromPath)
      var multipartFile = http.MultipartFile(
        'profileImage', // Field name must match multer.single("profileImage")
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      if (kDebugMode) {
        print('uploadProfileImage - File field name: profileImage');
        print('uploadProfileImage - Request method: PUT');
        print('uploadProfileImage - Sending request...');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('==========================================');
        print('uploadProfileImage - Response status: ${response.statusCode}');
        print('uploadProfileImage - Response body: ${response.body}');
        print('==========================================');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        // Backend returns { message, updatedStudent }, so extract updatedStudent
        if (data.containsKey('updatedStudent')) {
          if (kDebugMode) {
            print(
                'uploadProfileImage - Success! Updated student data received');
          }
          return Student.fromJson(data['updatedStudent']);
        }
        return Student.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Student with schoolId "$cleanSchoolId" not found.');
      } else if (response.statusCode == 400) {
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Invalid image provided';
          if (kDebugMode) {
            print('uploadProfileImage - 400 Error: $errorMsg');
          }
          throw Exception(errorMsg);
        } catch (e) {
          if (e.toString().contains('Exception:')) rethrow;
          throw Exception('Invalid image provided: ${response.body}');
        }
      } else if (response.statusCode == 500) {
        // Parse server error for more details
        if (kDebugMode) {
          print('uploadProfileImage - 500 Error received');
          print(
              'uploadProfileImage - Response body type: ${response.body.contains('<!DOCTYPE') ? 'HTML' : 'JSON'}');
        }

        // Check if response is HTML (backend crash) or JSON (handled error)
        if (response.body.contains('<!DOCTYPE') ||
            response.body.contains('<html')) {
          if (kDebugMode) {
            print('uploadProfileImage - Backend returned HTML error page');
            print(
                'uploadProfileImage - This usually means the endpoint is missing multer middleware');
          }
          throw Exception(
              'Backend configuration error. The server endpoint may be missing file upload middleware (multer). Please check your backend route configuration.');
        }

        // Try to parse JSON error
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Server error';
          if (errorData['error'] != null) {
            errorMsg += ' - ${errorData['error']}';
          }
          if (kDebugMode) {
            print('uploadProfileImage - 500 Error: $errorMsg');
            print('uploadProfileImage - Full error data: $errorData');
          }
          throw Exception(errorMsg);
        } catch (e) {
          if (e.toString().contains('Exception:')) rethrow;
          throw Exception('Server error while uploading image.');
        }
      } else {
        throw Exception(
            'Failed to upload profile image. Status: ${response.statusCode}, Response: ${response.body}');
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) print('uploadProfileImage - Network error: $e');
      throw Exception('Network error. Please check your internet connection.');
    } on SocketException catch (e) {
      if (kDebugMode) print('uploadProfileImage - Socket error: $e');
      throw Exception('Cannot connect to server. Is the server running?');
    } catch (error) {
      if (kDebugMode) print('uploadProfileImage - Unexpected error: $error');
      if (error.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }

  /// Updates student profile with image upload
  Future<Student> updateStudentProfile(
      String schoolId, Map<String, dynamic> updates, File? imageFile) async {
    try {
      // Trim schoolId to remove any whitespace
      final cleanSchoolId = schoolId.trim();
      var url =
          Uri.parse("$apiUrl/student/updateStudentProfile/$cleanSchoolId");

      if (kDebugMode) {
        print('Updating profile for schoolId: $cleanSchoolId');
        print('API URL: $url');
        print('Updates: $updates');
        print('Has image: ${imageFile != null}');
      }

      http.Response response;

      // If there's an image, use multipart request
      if (imageFile != null) {
        var request = http.MultipartRequest('PUT', url);

        // Add text fields
        updates.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            request.fields[key] = value.toString();
          }
        });

        // Add image file
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'profileImage',
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);

        if (kDebugMode) {
          print('Request fields: ${request.fields}');
          print('Request files: ${request.files.length}');
        }

        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // If no image, use regular JSON PUT request
        if (kDebugMode) {
          print('Sending JSON request body: ${jsonEncode(updates)}');
        }

        response = await http.put(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(updates),
        );
      }

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        // Backend returns { message, updatedStudent }, so extract updatedStudent
        if (data.containsKey('updatedStudent')) {
          return Student.fromJson(data['updatedStudent']);
        }
        return Student.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception(
            'Student with schoolId "$cleanSchoolId" not found. Please verify your school ID.');
      } else if (response.statusCode == 400) {
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Invalid data provided');
        } catch (e) {
          throw Exception('Invalid data provided: ${response.body}');
        }
      } else if (response.statusCode == 500) {
        // Better handling for 500 errors
        try {
          Map<String, dynamic> errorData = jsonDecode(response.body);
          String errorMsg = errorData['message'] ?? 'Server error';
          if (errorData['error'] != null) {
            errorMsg += ' - ${errorData['error']['name'] ?? 'Unknown error'}';
          }
          throw Exception(errorMsg);
        } catch (e) {
          throw Exception('Server error occurred. Please try again later.');
        }
      } else {
        throw Exception(
            'Failed to update student profile. Status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) print('Network error: $e');
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException catch (e) {
      if (kDebugMode) print('Format error: $e');
      throw Exception('Invalid response format from the server.');
    } catch (error) {
      if (kDebugMode) print('Update error: $error');
      if (error.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }
}
