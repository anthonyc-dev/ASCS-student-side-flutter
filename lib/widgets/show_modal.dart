import 'package:flutter/cupertino.dart';
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
}
