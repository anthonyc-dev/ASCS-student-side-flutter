import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/models/student_requirement.dart';
import 'package:my_app/services/student_requirement_service.dart';
import 'package:my_app/widgets/clearance/build_info_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<StudentInstitutionalRequirement> _institutionalRequirements = [];
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

      final requirements = await _requirementService
          .getStudentInstitutionalRequirementsByStudentId(schoolId);
      if (!mounted) return;
      setState(() {
        _institutionalRequirements = requirements;
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
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
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
                    )
                  : ListView.builder(
                      itemCount: _institutionalRequirements.length,
                      itemBuilder: (context, index) {
                        final requirement = _institutionalRequirements[index];
                        Color statusColor = getStatusColor(requirement.status);
                        IconData statusIcon = getStatusIcon(requirement.status);

                        return Container(
                          margin: const EdgeInsets.only(
                              top: 16, left: 16, right: 16),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.account_balance,
                                            size: 20, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Text(
                                          requirement.institutionalRequirement
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
                                        color:
                                            statusColor.withValues(alpha: 0.1),
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
                                  value: requirement.clearingOfficer.fullName,
                                ),
                                InfoRow(
                                  icon: Icons.assignment,
                                  label: 'Requirements',
                                  value: requirement.institutionalRequirement
                                      .requirementsString,
                                ),
                                InfoRow(
                                  icon: Icons.file_copy,
                                  label: 'Description',
                                  value: requirement
                                      .institutionalRequirement.description,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
