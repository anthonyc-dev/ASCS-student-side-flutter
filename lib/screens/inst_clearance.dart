import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/student_requirement.dart';
import 'package:my_app/models/clearance.dart';
import 'package:my_app/services/student_requirement_service.dart';
import 'package:my_app/services/clearance_service.dart';
import 'package:my_app/widgets/clearance/build_info_row.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class InstClearance extends StatefulWidget {
  const InstClearance({super.key});

  @override
  State<InstClearance> createState() => _InstClearanceState();
}

class _InstClearanceState extends State<InstClearance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentRequirementService _requirementService =
      StudentRequirementService();
  final ClearanceService _clearanceService = ClearanceService();
  List<StudentInstitutionalRequirement> _institutionalRequirements = [];
  Clearance? _currentClearance;
  bool _isLoading = false;
  String? _errorMessage;

  Color getStatusColor(String status) {
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

  IconData getStatusIcon(String status) {
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

  Future<void> _loadInstitutionalRequirements() async {
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
      final requirements = await _requirementService
          .getStudentInstitutionalRequirementsByStudentId(schoolId);
      final clearance = await _clearanceService.getCurrentClearance();

      if (!mounted) return;
      setState(() {
        _institutionalRequirements = requirements;
        _currentClearance = clearance;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        if (!mounted) return;
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
    _loadInstitutionalRequirements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Refresh function
  Future<void> _refreshData() async {
    await _loadInstitutionalRequirements();
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
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.white, // color of the spinner
      backgroundColor: Colors.blue,
      child: _isLoading
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              ),
            )
          : _errorMessage != null
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(
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
                              onPressed: _loadInstitutionalRequirements,
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
                    ),
                  ),
                )
              : _institutionalRequirements.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Show status card if clearance ended or stopped
                          if (_shouldShowStatusCard())
                            _buildClearanceStatusCard(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Show status card if clearance ended or stopped
                        if (_shouldShowStatusCard())
                          _buildClearanceStatusCard(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _institutionalRequirements.length,
                            itemBuilder: (context, index) {
                              final requirement =
                                  _institutionalRequirements[index];
                              Color statusColor =
                                  getStatusColor(requirement.status);
                              IconData statusIcon =
                                  getStatusIcon(requirement.status);

                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 16, left: 16, right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.account_balance,
                                                  size: 20, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Text(
                                                requirement
                                                    .institutionalRequirement
                                                    .institutionalName,
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
                                              color: statusColor.withValues(
                                                  alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                                  requirement.status,
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
                                        value: requirement
                                            .clearingOfficer.fullName,
                                      ),
                                      InfoRow(
                                        icon: Icons.assignment,
                                        label: 'Requirements',
                                        value: requirement
                                            .institutionalRequirement
                                            .requirementsString,
                                      ),
                                      InfoRow(
                                        icon: Icons.file_copy,
                                        label: 'Description',
                                        value: requirement
                                            .institutionalRequirement
                                            .description,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
