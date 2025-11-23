import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogUtil {
  static void showSuccessDialog(
    BuildContext context,
    String message, {
    String? route = "/home",
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Success',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            style: GoogleFonts.outfit(fontSize: 15),
          ),
        ),
        actions: [
          if (route != null && route.isNotEmpty)
            CupertinoDialogAction(
              child: const Text('Back'),
              onPressed: () => Navigator.pop(context),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              if (route != null && route.isNotEmpty) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
        ],
      ),
    );
  }

  static void showRequirementsClearedDialog(
    BuildContext context, {
    VoidCallback? onViewQrCode,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Congratulations!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'All your requirements have been cleared!',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your clearance permit is now ready.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onViewQrCode != null) {
                      onViewQrCode();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'View QR Code',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
