import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/student.dart';
import 'package:my_app/models/clearance.dart';
import 'package:my_app/screens/nonifiocation.dart';
import 'package:my_app/services/student_profile_service.dart';
import 'package:my_app/services/clearance_service.dart';
import 'package:my_app/services/student_requirement_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final StudentProfileService _profileService = StudentProfileService();
  final ClearanceService _clearanceService = ClearanceService();
  final StudentRequirementService _requirementService =
      StudentRequirementService();

  Student? _student;
  Clearance? _currentClearance;
  int _signedCount = 0;
  int _totalRequirements = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final schoolId = prefs.getString('userSchoolId');

      if (schoolId != null && schoolId.isNotEmpty) {
        // Fetch student profile
        final student = await _profileService.getStudentBySchoolId(schoolId);

        // Fetch current clearance
        final clearance = await _clearanceService.getCurrentClearance();

        // Fetch requirements to calculate progress
        int signedCount = 0;
        int totalCount = 0;

        try {
          // Fetch both types of requirements
          final courseRequirements = await _requirementService
              .getStudentRequirementsBySchoolId(schoolId);
          final institutionalRequirements = await _requirementService
              .getStudentInstitutionalRequirementsByStudentId(schoolId);
          // Count total and signed requirements
          totalCount =
              courseRequirements.length + institutionalRequirements.length;
          signedCount = courseRequirements
                  .where((req) => req.status?.toLowerCase() == 'signed')
                  .length +
              institutionalRequirements
                  .where((req) => req.status?.toLowerCase() == 'signed')
                  .length;
        } catch (e) {
          if (kDebugMode) {
            print('ERROR fetching requirements: $e');
          }
        }

        if (!mounted) return;
        setState(() {
          _student = student;
          _currentClearance = clearance;
          _signedCount = signedCount;
          _totalRequirements = totalCount;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      // If API fails, continue with loading state false
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Header with Stats
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A84FF),
                    Color(0xFF0066CC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Display dynamic user data
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white70,
                                  ),
                                )
                              : Text(
                                  "${_student?.fullName ?? 'Unknown Student'} • ${_student?.schoolId ?? 'N/A'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),

                      // Actions (Notification + Profile Avatar)
                      Row(
                        children: [
                          // Notification Bell with Badge
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('notifications')
                                .orderBy('createdAt', descending: true)
                                .snapshots(includeMetadataChanges: false),
                            builder: (context, snapshot) {
                              if (kDebugMode) {
                                print(
                                    'Notification Stream Update: ${snapshot.data?.docs.length ?? 0} notifications');
                              }

                              final notificationCount = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const NotificationScreen(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));
                                              var offsetAnimation =
                                                  animation.drive(tween);

                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      splashRadius: 24,
                                    ),
                                  ),
                                  // Badge
                                  if (notificationCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Center(
                                          child: Text(
                                            notificationCount > 99
                                                ? '99+'
                                                : '$notificationCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),

                  // Search Bar
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const SearchScreen(),
                  //       ),
                  //     );
                  //   },
                  //   child: const AbsorbPointer(
                  //     child: TextField(
                  //       readOnly: true,
                  //       style: TextStyle(color: Colors.black87),
                  //       decoration: InputDecoration(
                  //         fillColor: Colors.white,
                  //         border: OutlineInputBorder(
                  //           borderSide: BorderSide.none,
                  //           borderRadius: BorderRadius.all(
                  //             Radius.circular(12),
                  //           ),
                  //         ),
                  //         hintText: "Search course...",
                  //         hintStyle: TextStyle(color: Colors.grey),
                  //         prefixIcon: Icon(Icons.search, color: Colors.grey),
                  //         filled: true,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressCard(
                          title: "Clearance",
                          percentage: _totalRequirements > 0
                              ? ((_signedCount / _totalRequirements) * 100)
                                  .round()
                              : 0,
                          color: Colors.white,
                          textColor: const Color(0xFF0A84FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildProgressCard(
                          title: "Requirements",
                          percentage: _totalRequirements > 0
                              ? ((_signedCount / _totalRequirements) * 100)
                                  .round()
                              : 0,
                          color: Colors.white,
                          textColor: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Clearance Deadline Card
                  if (_currentClearance != null) ...[
                    _shouldShowStatusCard()
                        ? _buildClearanceStatusCard()
                        : _buildDeadlineCard(),
                  ],
                  const SizedBox(height: 25),
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Grid Menu
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildModernCard(
                        title: "My Profile",
                        subtitle: "View & Edit",
                        icon: Icons.person_rounded,
                        color: const Color(0xFF0A84FF),
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                      _buildModernCard(
                        title: "Clearances",
                        subtitle: "Track Progress",
                        icon: Icons.description_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => Navigator.pushNamed(context, '/clearance'),
                      ),
                      _buildModernCard(
                        title: "Events",
                        subtitle: "Upcoming",
                        icon: Icons.event_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => Navigator.pushNamed(context, '/event'),
                      ),
                      // Notifications Card with Real-time Count
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .orderBy('createdAt', descending: true)
                            .snapshots(includeMetadataChanges: false),
                        builder: (context, snapshot) {
                          final notificationCount =
                              snapshot.hasData ? snapshot.data!.docs.length : 0;

                          return _buildModernCard(
                            title: "Notifications",
                            subtitle: notificationCount > 0
                                ? "$notificationCount New"
                                : "No New",
                            icon: Icons.notifications_rounded,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => Navigator.pushNamed(context, '/notif'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Check if should show status card instead of deadline ---
  bool _shouldShowStatusCard() {
    if (_currentClearance == null) return false;
    final now = DateTime.now();
    final deadline = _currentClearance!.effectiveDeadline;
    // Show status card if clearance is not active or deadline has passed
    return !_currentClearance!.isActive || now.isAfter(deadline);
  }

  // --- Clearance Status Card (Ended/Stopped) ---
  Widget _buildClearanceStatusCard() {
    final now = DateTime.now();
    final deadline = _currentClearance!.effectiveDeadline;
    final hasEnded = now.isAfter(deadline);
    final isStopped = !_currentClearance!.isActive;

    String title;
    String message;
    IconData icon;
    List<Color> gradientColors;

    if (isStopped && hasEnded) {
      title = "Clearance Stopped";
      message = "Ended on ${DateFormat('MMM dd, yyyy').format(deadline)}";
      icon = Icons.block_rounded;
      gradientColors = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    } else if (isStopped) {
      title = "Clearance Stopped";
      message = "This clearance has been deactivated";
      icon = Icons.block_rounded;
      gradientColors = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    } else if (hasEnded) {
      title = "Clearance Ended";
      message = "Ended on ${DateFormat('MMM dd, yyyy').format(deadline)}";
      icon = Icons.event_busy_rounded;
      gradientColors = [const Color(0xFFEF4444), const Color(0xFFDC2626)];
    } else {
      // Fallback (shouldn't reach here based on _shouldShowStatusCard logic)
      title = "Clearance Status";
      message = "Status unavailable";
      icon = Icons.info_rounded;
      gradientColors = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
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

  // --- Deadline Card ---
  Widget _buildDeadlineCard() {
    final deadline = _currentClearance!.effectiveDeadline;
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    final isOverdue = daysLeft < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverdue
              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
              : [const Color(0xFF0A84FF), const Color(0xFF0066CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isOverdue ? const Color(0xFFEF4444) : const Color(0xFF0A84FF))
                    .withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOverdue ? Icons.warning_rounded : Icons.calendar_today_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? "Clearance Overdue" : "Clearance Deadline",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(deadline),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOverdue
                  ? "${daysLeft.abs()} days ago"
                  : daysLeft == 0
                      ? "Today"
                      : "$daysLeft days left",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Progress Card ---
  Widget _buildProgressCard({
    required String title,
    required int percentage,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 6,
                    backgroundColor: textColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
                Text(
                  "$percentage%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- Modern Card ---
  Widget _buildModernCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
