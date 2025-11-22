import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/services/student_profile_service.dart';

/// Simple test screen to debug image upload
/// Use this to isolate and test the image upload functionality
class TestImageUploadScreen extends StatefulWidget {
  const TestImageUploadScreen({super.key});

  @override
  State<TestImageUploadScreen> createState() => _TestImageUploadScreenState();
}

class _TestImageUploadScreenState extends State<TestImageUploadScreen> {
  final StudentProfileService _service = StudentProfileService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _schoolIdController = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;
  String? _statusMessage;
  Color _statusColor = Colors.black;
  Student? _mockStudent;

  @override
  void initState() {
    super.initState();
    // Create a mock student for testing
    _mockStudent = Student(
      id: 'test-id',
      schoolId: 'TEST-001', // Default test school ID
      firstName: 'Test',
      lastName: 'Student',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      program: 'Computer Science',
      yearLevel: '4th Year',
    );
    _schoolIdController.text = _mockStudent!.schoolId;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _statusMessage = 'Picking image...';
        _statusColor = Colors.blue;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        print('✅ Image picked successfully');
        print('   Path: ${pickedFile.path}');
        print('   Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

        setState(() {
          _selectedImage = file;
          _statusMessage =
              'Image selected (${(fileSize / 1024).toStringAsFixed(2)} KB)';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _statusMessage = 'No image selected';
          _statusColor = Colors.orange;
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      setState(() {
        _statusMessage = 'Error picking image: $e';
        _statusColor = Colors.red;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _statusMessage = 'Please select an image first';
        _statusColor = Colors.orange;
      });
      return;
    }

    final schoolId = _schoolIdController.text.trim();
    if (schoolId.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a school ID';
        _statusColor = Colors.orange;
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = 'Uploading image...';
      _statusColor = Colors.blue;
    });

    print('\n╔════════════════════════════════════════╗');
    print('║     STARTING IMAGE UPLOAD TEST         ║');
    print('╚════════════════════════════════════════╝');
    print('School ID: $schoolId');
    print('Image path: ${_selectedImage!.path}');
    print('Image size: ${await _selectedImage!.length()} bytes');
    print('API URL: ${_service.apiUrl}');

    try {
      final updatedStudent = await _service.uploadProfileImage(
        schoolId,
        _selectedImage!,
        _mockStudent!,
      );

      print('\n╔════════════════════════════════════════╗');
      print('║     ✅ UPLOAD SUCCESSFUL!              ║');
      print('╚════════════════════════════════════════╝');
      print('Updated student: ${updatedStudent.fullName}');
      print('Profile image URL: ${updatedStudent.profileImage}');

      setState(() {
        _isUploading = false;
        _statusMessage =
            '✅ Upload successful!\nProfile image: ${updatedStudent.profileImage}';
        _statusColor = Colors.green;
        _selectedImage = null; // Clear selection
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile image uploaded successfully!'),
                const SizedBox(height: 8),
                Text(
                  'Student: ${updatedStudent.fullName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Image URL: ${updatedStudent.profileImage}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('\n╔════════════════════════════════════════╗');
      print('║     ❌ UPLOAD FAILED!                  ║');
      print('╚════════════════════════════════════════╝');
      print('Error: $e');

      setState(() {
        _isUploading = false;
        _statusMessage = '❌ Upload failed:\n$e';
        _statusColor = Colors.red;
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Upload Failed'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(e.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Image Upload'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Image Upload Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This screen helps test the image upload functionality.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'API: ${_service.apiUrl}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // School ID input
            TextField(
              controller: _schoolIdController,
              decoration: InputDecoration(
                labelText: 'School ID',
                hintText: 'Enter student school ID',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge),
                helperText: 'The student must exist in the database',
              ),
            ),

            const SizedBox(height: 24),

            // Image preview
            if (_selectedImage != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Pick image buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Upload button
            ElevatedButton.icon(
              onPressed:
                  _isUploading || _selectedImage == null ? null : _uploadImage,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Status message
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  border: Border.all(color: _statusColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _statusColor == Colors.green
                          ? Icons.check_circle
                          : _statusColor == Colors.red
                              ? Icons.error
                              : Icons.info,
                      color: _statusColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Testing Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      '1',
                      'Make sure your backend server is running',
                    ),
                    _buildInstructionItem(
                      '2',
                      'Enter a valid school ID from your database',
                    ),
                    _buildInstructionItem(
                      '3',
                      'Select an image from gallery or camera',
                    ),
                    _buildInstructionItem(
                      '4',
                      'Click "Upload Image" and check logs',
                    ),
                    _buildInstructionItem(
                      '5',
                      'Check both Flutter console and backend console',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _schoolIdController.dispose();
    super.dispose();
  }
}
