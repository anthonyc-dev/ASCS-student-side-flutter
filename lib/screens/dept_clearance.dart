import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/student_requirement.dart';
import 'package:my_app/models/clearance.dart';
import 'package:my_app/screens/inst_clearance.dart';
import 'package:my_app/screens/qr_code.dart';
import 'package:my_app/services/student_requirement_service.dart';
import 'package:my_app/services/clearance_service.dart';
import 'package:my_app/widgets/clearance/build_info_row.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DeptClearance extends StatefulWidget {
  const DeptClearance({super.key});

  @override
  State<DeptClearance> createState() => _DeptClearanceState();
}

class _DeptClearanceState extends State<DeptClearance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentRequirementService _requirementService =
      StudentRequirementService();
  final ClearanceService _clearanceService = ClearanceService();
  List<StudentRequirement> _studentRequirements = [];
  Clearance? _currentClearance;
  bool _isLoading = false;
  String? _errorMessage;

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'signed':
        return Colors.green;
      case 'pending':
      case 'incomplete':
        return Colors.orange;
      case 'missing':
      case 'unsigned':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  IconData getStatusIcon(String? status) {
    if (status == null) return Icons.info;
    switch (status.toLowerCase()) {
      case 'signed':
        return Icons.check_circle;
      case 'pending':
      case 'incomplete':
        return Icons.pending;
      case 'missing':
      case 'unsigned':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Future<void> _loadStudentRequirements() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final schoolId = prefs.getString('userSchoolId') ?? 'N/A';

      if (schoolId == 'N/A') {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'School ID not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // Fetch requirements and clearance in parallel
      final requirements =
          await _requirementService.getStudentRequirementsBySchoolId(schoolId);
      final clearance = await _clearanceService.getCurrentClearance();

      if (!mounted) return;
      setState(() {
        _studentRequirements = requirements;
        _currentClearance = clearance;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadStudentRequirements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Refresh function
  Future<void> _refreshData() async {
    await _loadStudentRequirements();
  }

  // --- Check if should show status card ---
  bool _shouldShowStatusCard() {
    if (_currentClearance == null) return false;
    final now = DateTime.now();
    final deadline = _currentClearance!.effectiveDeadline;
    return !_currentClearance!.isActive || now.isAfter(deadline);
  }

  // --- Build Clearance Status Card ---
  Widget _buildClearanceStatusCard() {
    if (_currentClearance == null) return const SizedBox.shrink();

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
      title = "Clearance Status";
      message = "Status unavailable";
      icon = Icons.info_rounded;
      gradientColors = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
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
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.outfit(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Text(
          'Clearance',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2, size: 30),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrCode()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business),
                  const SizedBox(width: 8),
                  Text(
                    "Department",
                    style: GoogleFonts.outfit(fontSize: 14),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance),
                  const SizedBox(width: 8),
                  Text(
                    "Institutional",
                    style: GoogleFonts.outfit(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Department Clearance Tab with pull-to-refresh
          RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.white, // color of the spinner
            backgroundColor: Colors.blue,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : Column(
                    children: [
                      // Show status card if clearance ended or stopped
                      if (_shouldShowStatusCard()) _buildClearanceStatusCard(),
                      Expanded(
                        child: _errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 60,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading requirements',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadStudentRequirements,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text(
                                          'Retry',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _studentRequirements.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 80,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No requirements found',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                    ),
                                    itemCount: _studentRequirements.length,
                                    itemBuilder: (context, index) {
                                      final requirement =
                                          _studentRequirements[index];
                                      Color statusColor =
                                          getStatusColor(requirement.status);
                                      IconData statusIcon =
                                          getStatusIcon(requirement.status);

                                      return GestureDetector(
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         CourseDetailsScreen(requirement: requirement),
                                          //   ),
                                          // );
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.class_,
                                                            size: 20,
                                                            color: Colors.blue),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          requirement
                                                                  .officerRequirement
                                                                  ?.courseCode ??
                                                              'N/A',
                                                          style: GoogleFonts
                                                              .outfit(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                          .grey[
                                                                      700]),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: statusColor
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            statusIcon,
                                                            color: statusColor,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            requirement
                                                                    .status ??
                                                                'Unknown',
                                                            style: GoogleFonts
                                                                .outfit(
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                                                  value: requirement
                                                          .clearingOfficer
                                                          ?.fullName ??
                                                      'N/A',
                                                ),
                                                InfoRow(
                                                  icon: Icons.assignment,
                                                  label: 'Requirements',
                                                  value: requirement
                                                          .officerRequirement
                                                          ?.requirementsString ??
                                                      'N/A',
                                                ),
                                                InfoRow(
                                                  icon: Icons.file_copy,
                                                  label: 'Description',
                                                  value: requirement
                                                          .officerRequirement
                                                          ?.description ??
                                                      'No description',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
          ),

          // Institutional Clearance Tab
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: InstClearance(),
            ),
          ),
        ],
      ),
    );
  }
}
