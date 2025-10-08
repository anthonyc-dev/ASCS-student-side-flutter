import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmsScreen extends StatelessWidget {
  const SmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SMS Feature Coming Soon!',
            style: GoogleFonts.outfit(fontSize: 20),
          ),
          Text("Hello World!", style: GoogleFonts.outfit(fontSize: 10)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'SMS feature is under development! One',
                    style: GoogleFonts.outfit(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Set background color
              foregroundColor: Colors.white, // Set text color
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text('Notify Me One', style: GoogleFonts.outfit()),
          ),
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Adds 16 pixels padding on all sides
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'SMS feature is under development! Two',
                      style: GoogleFonts.outfit(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Set background color
                foregroundColor: Colors.white, // Set text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text('Notify Me Two', style: GoogleFonts.outfit()),
            ),
          ),
        ],
      ),
    );
  }
}
