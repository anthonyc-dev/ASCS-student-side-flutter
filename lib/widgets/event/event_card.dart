import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final void Function()? onAddToCalendar;

  const EventCard({
    super.key,
    required this.event,
    this.onAddToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final String title = event['title'] ?? 'No Title';
    final String description = event['description'] ?? '';
    final String date = event['date'] ?? '';
    final String venue = event['venue'] ?? '';
    final Color iconColor = event['iconColor'] ?? Colors.blue;
    final Color buttonColor = event['buttonColor'] ?? Colors.blue;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Date Row
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18, color: iconColor.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Venue Row
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 20, color: iconColor.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Text(
                  venue,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Add to Calendar Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.event_available,
                    size: 18, color: Colors.white),
                label: const Text("Add to Calendar"),
                onPressed: onAddToCalendar ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Event added to calendar!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
