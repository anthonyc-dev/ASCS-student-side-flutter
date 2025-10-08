import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String rawStatus = (course['status'] ?? 'Pending').toString();
    final String statusKey = _normalizeStatus(rawStatus);
    final String displayStatus = _displayStatus(statusKey, rawStatus);
    final Color statusColor = _getStatusColor(statusKey);
    final IconData statusIcon = _getStatusIcon(statusKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Details',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= Header =======
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['courseCode'] ?? 'N/A',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                if ((course['courseName'] ?? '').toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      course['courseName'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ======= Status Chip =======
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  displayStatus,
                  style: GoogleFonts.outfit(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(height: 2),

            // ======= Information Section =======
            const SizedBox(height: 20),
            if (course['instructor'] != null)
              _InfoTile(
                icon: Icons.person_outline,
                label: 'Instructor',
                value: course['instructor'].toString(),
              ),
            if (course['schedule'] != null)
              _InfoTile(
                icon: Icons.schedule_outlined,
                label: 'Schedule',
                value: course['schedule'].toString(),
              ),
            if (course['section'] != null)
              _InfoTile(
                icon: Icons.group_outlined,
                label: 'Section',
                value: course['section'].toString(),
              ),
            if (course['requirements'] != null)
              _InfoTile(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Requirements',
                value: course['requirements'].toString(),
              ),

            const SizedBox(height: 12),

            // ======= Description =======
            if (course['description'] != null) ...[
              Text(
                'Description',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                course['description'].toString(),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 36),

            // ======= Action Buttons =======
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FlatButton(
                  label: 'Back',
                  icon: Icons.arrow_back,
                  color: Colors.grey[300]!,
                  textColor: Colors.black87,
                  onTap: () => Navigator.pop(context),
                ),
                _FlatButton(
                  label: 'Action',
                  icon: Icons.check_circle_outline,
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Feature coming soon!',
                          style: GoogleFonts.outfit(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Normalizes status: lowercase, trim and remove non-alphanumerics
  String _normalizeStatus(String status) {
    return status.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // Friendly display label for the status
  String _displayStatus(String normalized, String raw) {
    switch (normalized) {
      case 'sign':
      case 'signed':
        return 'Signed';
      case 'cleared':
        return 'Cleared';
      case 'pending':
        return 'Pending';
      case 'incomplete':
        return 'In complete';
      case 'missing':
        return 'Missing';
      case 'notcleared':
        return 'Not cleared';
      default:
        return raw;
    }
  }

  Color _getStatusColor(String normalized) {
    switch (normalized) {
      case 'sign':
      case 'signed':
      case 'cleared':
        return Colors.green;
      case 'incomplete':
        return Colors.orange;
      case 'missing':
      case 'notcleared':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String normalized) {
    switch (normalized) {
      case 'sign':
      case 'signed':
      case 'cleared':
        return Icons.check_circle_outline;
      case 'incomplete':
        return Icons.pending_outlined;
      case 'missing':
        return Icons.cancel_outlined;
      case 'notcleared':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

// ======= SUPPORTING WIDGETS =======

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _FlatButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
