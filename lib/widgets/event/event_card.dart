import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final void Function()? onAddToCalendar;

  const EventCard({
    super.key,
    required this.event,
    this.onAddToCalendar,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    final String title = widget.event['title'] ?? 'No Title';
    final String description = widget.event['description'] ?? '';
    final String date = widget.event['date'] ?? '';
    final String? time = widget.event['time'];
    final String venue = widget.event['venue'] ?? '';
    final Color iconColor = widget.event['iconColor'] ?? Colors.blue;

    // Combine date and time for display
    final String dateTimeDisplay =
        time != null && time.isNotEmpty ? '$date at $time' : date;

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
                Flexible(
                  child: Text(
                    dateTimeDisplay,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
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

            // // Add to Calendar Button
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: ElevatedButton.icon(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: buttonColor,
            //       foregroundColor: Colors.white,
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     icon: _isAdding
            //         ? const SizedBox(
            //             width: 16,
            //             height: 16,
            //             child: CircularProgressIndicator(
            //               color: Colors.white,
            //               strokeWidth: 2,
            //             ),
            //           )
            //         : const Icon(Icons.event_available,
            //             size: 18, color: Colors.white),
            //     label: Text(
            //       _isAdding ? "Adding..." : "Add to Calendar",
            //       style: const TextStyle(color: Colors.white),
            //     ),
            //     onPressed: _isAdding
            //         ? null
            //         : widget.onAddToCalendar ?? () => _addToCalendar(context),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
