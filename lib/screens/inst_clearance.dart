import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/widgets/clearance/build_info_row.dart';

class InstClearance extends StatefulWidget {
  const InstClearance({super.key});

  @override
  State<InstClearance> createState() => _InstClearanceState();
}

class _InstClearanceState extends State<InstClearance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data for the table
  final List<Map<String, String>> courseData = [
    {
      'courseCode': 'SOA',
      'instructor': 'Mariam Christine Abilla',
      'requirements': 'Sign by SGO and UMSA',
      'status': 'Sign',
      "dueDate": '2024-10-01',
    },
    {
      'courseCode': 'Registrar',
      'instructor': 'Salman Sultan',
      'requirements': 'Sign all Subject and form !#&',
      'status': 'In complete',
      "dueDate": '2024-10-05',
    },
    {
      'courseCode': 'Tailoring',
      'instructor': 'Bilinda Sahok',
      'requirements': 'Ncmc Uniform and Student ID',
      'status': 'Sign',
      "dueDate": '2024-10-03',
    },
    {
      'courseCode': 'Laboratory',
      'instructor': 'Romel Etang',
      'requirements': 'One mouse and keyboard',
      'status': 'Missing',
      "dueDate": '2024-10-07',
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'Sign':
        return Colors.green;
      case 'In complete':
        return Colors.orange;
      case 'Missing':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Sign':
        return Icons.check_circle;
      case 'In complete':
        return Icons.pending;
      case 'Missing':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Refresh function
  Future<void> _refreshData() async {
    // Simulate network request delay
    await Future.delayed(const Duration(seconds: 2));

    // Example:
    // final updatedCourses = await ApiService.getCourses();
    // setState(() => courseData = updatedCourses);

    setState(() {
      // For demo, we shuffle the list to simulate updated data
      courseData.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.white, // color of the spinner
        backgroundColor: Colors.blue,
        child: ListView.builder(
          itemCount: courseData.length,
          itemBuilder: (context, index) {
            final course = courseData[index];
            Color statusColor = getStatusColor(course['status']!);
            IconData statusIcon = getStatusIcon(course['status']!);

            return Container(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.class_,
                                size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              course['courseCode']!,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                course['status']!,
                                style: GoogleFonts.outfit(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InfoRow(
                        icon: Icons.person,
                        label: 'Instructor',
                        value: course['instructor']!),
                    InfoRow(
                        icon: Icons.assignment,
                        label: 'Requirements',
                        value: course['requirements']!),
                    InfoRow(
                        icon: Icons.schedule,
                        label: 'Due Date',
                        value: course['dueDate']!),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
