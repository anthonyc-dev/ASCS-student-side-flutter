import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/student_requirement.dart';
import 'package:my_app/models/clearance.dart';
import 'package:my_app/screens/inst_clearance.dart';
import 'package:my_app/screens/qr_code.dart';
import 'package:my_app/services/student_requirement_service.dart';
import 'package:my_app/services/clearance_service.dart';
import 'package:my_app/services/socket_service.dart';
import 'package:my_app/widgets/clearance/build_info_row.dart';
import 'package:my_app/widgets/show_modal.dart';
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
  final SocketService _socketService = SocketService();
  List<StudentRequirement> _studentRequirements = [];
  Clearance? _currentClearance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentSchoolId;

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

      // Store school ID for real-time updates
      _currentSchoolId = schoolId;

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

  // Handle real-time requirement creation from Socket.IO
  void _handleRequirementCreated(dynamic data) {
    if (!mounted) return;
    // ignore: avoid_print
    print('📥 Processing requirement:created event: $data');

    try {
      // Backend emits either {count: N} or {count: N, requirements: [...], requirementDetails: {...}}
      int newRequirementsCount = 0;

      if (data is Map) {
        // Check if this is a createMany result with count
        if (data.containsKey('count')) {
          newRequirementsCount = data['count'] as int;
        }

        // If backend sends full data with requirements array
        if (data.containsKey('requirements') && data['requirements'] is List) {
          final requirements = data['requirements'] as List;
          // Filter for current student if studentId is available
          if (_currentSchoolId != null) {
            final relevantReqs = requirements.where((item) {
              return item['studentId'] == _currentSchoolId;
            }).toList();
            newRequirementsCount = relevantReqs.length;
          }
        }
      } else if (data is List) {
        // If backend sends array of student requirements directly
        if (_currentSchoolId != null) {
          final relevantReqs = data.where((item) {
            return item['studentId'] == _currentSchoolId;
          }).toList();
          newRequirementsCount = relevantReqs.length;
        }
      }

      // Refresh if there are new requirements
      if (newRequirementsCount > 0 || data != null) {
        // ignore: avoid_print
        print('✅ New requirement(s) detected - refreshing data');

        // Auto-refresh the requirements list to show new data (silent - no loading spinner)
        _silentRefresh();
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error processing requirement:created event: $e');
      // Refresh anyway to be safe (silent refresh)
      _silentRefresh();
    }
  }

  // Handle real-time requirement status updates from Socket.IO
  void _handleRequirementUpdated(dynamic data) {
    if (!mounted || _currentSchoolId == null) return;
    // ignore: avoid_print
    print('📥 Processing studentRequirementUpdated event: $data');

    try {
      if (data is! Map) {
        // ignore: avoid_print
        print('⚠️ Invalid data format for requirement update');
        return;
      }

      final studentId = data['studentId'] as String?;
      final status = data['status'] as String?;

      // Check if this update is for the current student
      if (studentId != _currentSchoolId) {
        // ignore: avoid_print
        print('ℹ️ Update is for different student, ignoring');
        return;
      }
      // ignore: avoid_print
      print('✅ Requirement status updated for current student: $status');

      // Silently refresh to get the updated data
      _silentRefresh();
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error processing requirement update event: $e');
      // Refresh anyway to be safe
      _silentRefresh();
    }
  }

  // Handle real-time requirement deletion from Socket.IO
  void _handleRequirementDeleted(dynamic data) {
    if (!mounted || _currentSchoolId == null) return;
    // ignore: avoid_print
    print('📥 Processing requirement:deleted event: $data');

    try {
      if (data is! Map) {
        // ignore: avoid_print
        print('⚠️ Invalid data format for requirement deletion');
        return;
      }

      final studentId = data['studentId'] as String?;
      final requirementId = data['requirementId'] as String?;

      // Check if this deletion is for the current student
      if (studentId != _currentSchoolId) {
        // ignore: avoid_print
        print('ℹ️ Deletion is for different student, ignoring');
        return;
      }
      // ignore: avoid_print
      print(
          '✅ Requirement deleted for current student: $requirementId - updating display');

      // Silently refresh to remove the deleted requirement from the list
      // No notification - just update the display in real-time
      _silentRefresh();
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error processing requirement deletion event: $e');
      // Refresh anyway to be safe
      _silentRefresh();
    }
  }

  // Handle all requirements cleared event
  void _handleAllRequirementsCleared(dynamic data) {
    if (!mounted || _currentSchoolId == null) return;
    // ignore: avoid_print
    print('📥 Processing requirements:allCleared event: $data');

    try {
      if (data is! Map) {
        // ignore: avoid_print
        print('⚠️ Invalid data format for requirements cleared');
        return;
      }

      final studentId = data['studentId'] as String?;

      // Check if this is for the current student
      if (studentId != _currentSchoolId) {
        // ignore: avoid_print
        print('ℹ️ Clearance is for different student, ignoring');
        return;
      }

      // ignore: avoid_print
      print('✅ All requirements cleared for current student!');

      // Show the requirements cleared modal
      DialogUtil.showRequirementsClearedDialog(
        context,
        onViewQrCode: () {
          // Navigate to QR Code screen
          Navigator.pushNamed(context, '/qr-code');
        },
      );

      // Silently refresh to update the UI with cleared status
      _silentRefresh();
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error processing requirements cleared event: $e');
    }
  }

  // Handle QR code generated event
  void _handleQrGenerated(dynamic data) {
    if (!mounted || _currentSchoolId == null) return;
    // ignore: avoid_print
    print('📥 Processing qr:generated event: $data');

    try {
      if (data is! Map) {
        // ignore: avoid_print
        print('⚠️ Invalid data format for QR generated');
        return;
      }

      final studentId = data['studentId'] as String?;

      // Check if this QR is for the current student
      if (studentId != _currentSchoolId) {
        // ignore: avoid_print
        print('ℹ️ QR generated for different student, ignoring');
        return;
      }

      // ignore: avoid_print
      print('✅ QR Code generated for current student!');

      // Show snackbar notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code has been generated!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Silently refresh to update the UI
      _silentRefresh();
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error processing QR generated event: $e');
    }
  }

  // Setup Socket.IO listeners
  void _setupSocketListeners() {
    // Connect to socket server
    _socketService.connect();

    // Listen for requirement creation events
    _socketService.onRequirementCreated(_handleRequirementCreated);

    // Listen for requirement status update events
    _socketService.onRequirementUpdated(_handleRequirementUpdated);

    // Listen for requirement deletion events
    _socketService.onRequirementDeleted(_handleRequirementDeleted);

    // Listen for all requirements cleared event
    _socketService.onAllRequirementsCleared(_handleAllRequirementsCleared);

    // Listen for QR code generation events
    _socketService.onQrGenerated(_handleQrGenerated);

    // Direct listener as backup (for debugging)
    if (_socketService.socket != null) {
      _socketService.socket!.on('requirement:deleted', (data) {
        // ignore: avoid_print
        print('🗑️ [DIRECT LISTENER] requirement:deleted received: $data');
        _handleRequirementDeleted(data);
      });
    }
    // ignore: avoid_print
    print('🔌 Socket listeners setup complete');
  }

  // Cleanup Socket.IO listeners
  void _cleanupSocketListeners() {
    _socketService.off('requirement:created');
    _socketService.off('studentRequirementUpdated');
    _socketService.off('requirement:deleted');
    _socketService.off('requirements:allCleared');
    _socketService.off('qr:generated');

    // ignore: avoid_print
    print('🔇 Socket listeners cleaned up');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadStudentRequirements();

    // Setup real-time Socket.IO connection
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Cleanup Socket.IO listeners
    _cleanupSocketListeners();

    super.dispose();
  }

  // Refresh function (with loading indicator for manual refresh)
  Future<void> _refreshData() async {
    await _loadStudentRequirements();
  }

  // Silent background refresh (no loading indicator - for real-time updates)
  Future<void> _silentRefresh() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final schoolId = prefs.getString('userSchoolId') ?? 'N/A';

      if (schoolId == 'N/A') return;

      // Fetch requirements and clearance in parallel
      final requirements =
          await _requirementService.getStudentRequirementsBySchoolId(schoolId);
      final clearance = await _clearanceService.getCurrentClearance();

      if (!mounted) return;
      setState(() {
        _studentRequirements = requirements;
        _currentClearance = clearance;
        // Don't change _isLoading or _errorMessage - keep current UI state
      });
// ignore: avoid_print
      print(
          '🔄 Silent refresh completed - ${requirements.length} requirements loaded');
    } catch (error) {
      // ignore: avoid_print
      print('⚠️ Silent refresh error: $error');
      // Don't show error to user - it's a background refresh
    }
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

  bool showQrButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A84FF),
                Color(0xFF0066CC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Clearance',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: showQrButton
            ? [
                IconButton(
                  icon: const Icon(Icons.qr_code_2, size: 30),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrCode(),
                      ),
                    );
                  },
                ),
              ]
            : [],
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
            color: Colors.white,
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
