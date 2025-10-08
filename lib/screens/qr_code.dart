import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QrCode extends StatelessWidget {
  const QrCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clearance QR Code", style: GoogleFonts.outfit()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR Code Section - Centered Image
            Center(
              child: SizedBox(
                width: 300, // Width of the QR code image
                height: 300, // Height of the QR code image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  child: Image.network(
                    'https://pngimg.com/d/qr_code_PNG33.png', // URL for the image
                    fit: BoxFit.cover, // Ensure image covers the container area
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Clearance Status Section - Positioned to the left
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green, // Green icon to show "Cleared"
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Clearance Status: Cleared',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Colors.green, // Green text to match the cleared status
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Second Semester Section - Left aligned with an icon
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  color: Colors.blue, // Blue icon for "Second Semester"
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Second Semester',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black text for second semester
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Midterm Examination Section - Left aligned with an icon
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: Colors.orange, // Orange icon for "Midterm Examination"
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Midterm Examination',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black text for midterm examination
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
