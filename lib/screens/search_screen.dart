import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/screens/course_details.dart';

// Sample course data
final List<Map<String, String>> courseData = [
  {
    'courseCode': 'CS101',
    'requirements': 'Calculator program',
    'instructor': 'Girly Aguilar',
    'status': 'Sign',
    "dueDate": '2024-10-01',
  },
  {
    'courseCode': 'CC107',
    'requirements': 'POS System',
    'instructor': 'Shayne Llup',
    'status': 'In complete',
    "dueDate": '2024-10-05',
  },
  {
    'courseCode': 'SE101',
    'requirements': 'Hardware System',
    'instructor': 'Jone Casipong',
    'status': 'Sign',
    "dueDate": '2024-10-03',
  },
  {
    'courseCode': 'CS Elect 1',
    'requirements': 'CS101',
    'instructor': 'Rosalyn Luzon',
    'status': 'Missing',
    "dueDate": '2024-10-07',
  },
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filteredCourses = courseData
        .where((course) =>
            course['courseCode']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Search Courses",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search course...",
                hintStyle:
                    const TextStyle(color: Colors.grey), // gray hint text
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey), // gray icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.grey), // gray border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.grey), // gray border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Colors.blue, width: 2), // darker on focus
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.grey), // gray input text
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),
          Expanded(
              child: filteredCourses.isEmpty
                  ? const Center(
                      child: Text(
                        "No courses found",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCourses.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailsScreen(course: course),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  // Left icon or leading circle
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.book_rounded,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Text content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course['courseCode'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right arrow icon
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
        ],
      ),
    );
  }
}

// class CourseDetailsPage extends StatelessWidget {
//   final Map<String, String> course;

//   const CourseDetailsPage({super.key, required this.course});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(course['courseCode'] ?? "Course Details",
//             style: GoogleFonts.outfit(
//               fontSize: 24,
//               color: Colors.white,
//             )),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Course Code: ${course['courseCode']}",
//                 style: GoogleFonts.outfit(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 )),
//             const SizedBox(height: 8),
//             Text("Requirements: ${course['requirements']}",
//                 style: GoogleFonts.outfit(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 )),
//             Text("Instructor: ${course['instructor']}",
//                 style: GoogleFonts.outfit(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 )),
//             Text("Status: ${course['status']}",
//                 style: GoogleFonts.outfit(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 )),
//             Text("Due Date: ${course['dueDate']}",
//                 style: GoogleFonts.outfit(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
