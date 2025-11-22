import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';
import '../services/permit_service.dart';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final SocketService _socketService = SocketService();
  final PermitService _permitService = PermitService();
  String? _qrImageBase64;
  bool _isLoading = true;
  String? _errorMessage;
  String? _studentId;
  Map<String, dynamic>? _permitData;

  @override
  void initState() {
    super.initState();
    _initializeQrListener();
  }

  Future<void> _initializeQrListener() async {
    // Get student ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getString('userSchoolId');

    if (_studentId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Student ID not found. Please log in again.';
      });
      return;
    }

    // Check if permit already exists for this student
    await _fetchExistingPermit();

    // Connect to socket if not already connected
    if (!_socketService.isConnected) {
      _socketService.connect();
    }

    // Listen for QR generation events
    _socketService.onQrGenerated((data) {
      // ignore: avoid_print
      print('QR Generated event received: $data');

      // Check if this QR is for the current student
      if (data['studentId'] == _studentId) {
        // Fetch the full permit data including QR image from API
        _fetchPermitData();
        _showQrGeneratedSnackbar();
      }
    });

    if (!mounted) return;
    // Initial state - waiting for QR generation
    setState(() {
      _isLoading = false;
    });
  }

  /// Fetch existing permit for the student (on screen load)
  Future<void> _fetchExistingPermit() async {
    if (_studentId == null) return;

    final permitData = await _permitService.getPermitByStudentId(_studentId!);
    if (permitData != null && mounted) {
      setState(() {
        _permitData = permitData['permit'];
        _qrImageBase64 = permitData['qrImage'];
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  /// Fetch permit data including QR image from API
  Future<void> _fetchPermitData() async {
    if (_studentId == null) return;

    setState(() {
      _isLoading = true;
    });

    final permitData = await _permitService.getPermitByStudentId(_studentId!);

    if (permitData != null && mounted) {
      setState(() {
        _permitData = permitData['permit'];
        _qrImageBase64 = permitData['qrImage'];
        _isLoading = false;
        _errorMessage = null;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch permit data';
      });
    }
  }

  void _showQrGeneratedSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code has been generated!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _socketService.off('qr:generated');
    super.dispose();
  }

  Widget _buildQrContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Waiting for QR code generation...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_permitData != null) {
      return _buildQrDisplay();
    }

    // No QR generated yet
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Waiting for clearance approval...',
            style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your QR code will appear here once\nall requirements are signed',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQrDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // QR Code Section - Centered Image
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: _qrImageBase64 != null
                  ? Image.memory(
                      base64Decode(_qrImageBase64!.split(',').last),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'https://pngimg.com/d/qr_code_PNG33.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Clearance Status Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _permitData?['status'] == 'active'
                  ? Icons.check_circle
                  : Icons.pending,
              color: _permitData?['status'] == 'active'
                  ? Colors.green
                  : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Clearance Status: ${_permitData?['status'] == 'active' ? 'Cleared' : 'Pending'}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _permitData?['status'] == 'active'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Permit Code Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Permit: ${_permitData?['permitCode'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Expiry Date Section
        if (_permitData?['expiresAt'] != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Expires: ${DateTime.parse(_permitData!['expiresAt']).toLocal().toString().split('.')[0]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clearance QR Code", style: GoogleFonts.outfit()),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A84FF),
                Color(0xFF0066CC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildQrContent(),
      ),
    );
  }
}
