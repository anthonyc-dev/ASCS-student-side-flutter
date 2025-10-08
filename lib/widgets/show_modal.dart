import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogUtil {
  static void showSuccessDialog(
    BuildContext context,
    String message, {
    String route = "/home",
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success", style: GoogleFonts.outfit()),
          content: Text(message, style: GoogleFonts.outfit()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacementNamed(
                  context,
                  route,
                ); // Navigate to specified route
              },
              child: Text("OK", style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    );
  }
}
