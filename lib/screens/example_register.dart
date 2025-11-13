import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/widgets/snackbar.dart';
import 'package:my_app/services/authentication.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  String? _selectedProgram;
  String? _selectedYearLevel;

  bool _agreePolicy = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final List<String> _programs = [
    "Bachelor of Science in Hospitality Management",
    "Electrical Engineering and Computer Science",
    "Bachelor of Science in Electrical Engineering",
    "Bachelor of Science in Criminology",
    "Bachelor of Science in Social Work",
    "Bachelor of Science in Accountancy",
    "PARAMED",
    "Bachelor of Science in Midwifery",
    "Bachelor of Science in Medical Technology",
    "Bachelor of Science in Nursing",
    "Bachelor of Science in Business Administration",
    "Bachelor of Elementary Education",
    "Bachelor of Arts in Political Science",
    "CEDCAS",
    "Bachelor in Secondary Education Major in Mathematics",
    "Bachelor in Secondary Education Major in Science",
    "Bachelor in Secondary Education Major in English",
    "All Departments",
  ];

  final List<String> _yearLevels = [
    "1st Year",
    "2nd Year",
    "3rd Year",
    "4th Year",
    "5th Year",
    "Old Student",
  ];

  void _signUp() async {
    if (!_formKey.currentState!.validate()) {
      showSnackBar(context, "Please fix the errors in the form.");
      return;
    }

    if (!_agreePolicy) {
      showSnackBar(context, "Please agree to the Privacy Policy first.");
      return;
    }

    setState(() => _isLoading = true);

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CupertinoAlertDialog(
        title: Text("Creating Account"),
        content: Padding(
          padding: EdgeInsets.only(top: 12),
          child: CupertinoActivityIndicator(radius: 14),
        ),
      ),
    );

    try {
      final auth = Authentication();
      final result = await auth.signUp(
        context: context,
        schoolId: _schoolIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        program: _selectedProgram!,
        yearLevel: _selectedYearLevel!,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      setState(() => _isLoading = false);

      if (result == "Success") {
        showSnackBar(context, "Account created successfully!");
        _clearFields();

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        showSnackBar(context, result);
      }
    } catch (error) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) showSnackBar(context, "Unexpected error: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _schoolIdController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _cpasswordController.clear();
    setState(() {
      _selectedProgram = null;
      _selectedYearLevel = null;
      _agreePolicy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0A84FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's create your account",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _firstNameController,
                        label: "First Name",
                        icon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty
                            ? "Enter first name"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _lastNameController,
                        label: "Last Name",
                        icon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty
                            ? "Enter last name"
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _schoolIdController,
                  label: "Student ID",
                  icon: Icons.badge_outlined,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter student ID" : null,
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _emailController,
                  label: "E-Mail",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter email";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter phone number";
                    if (val.length < 10) return "Invalid phone number";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ✅ Fixed Dropdown
                _buildDropdownFormField(
                  label: "Program",
                  icon: Icons.list_alt_outlined,
                  value: _selectedProgram,
                  items: _programs,
                  onChanged: (value) =>
                      setState(() => _selectedProgram = value),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Select program" : null,
                ),
                const SizedBox(height: 16),

                _buildDropdownFormField(
                  label: "Year Level",
                  icon: Icons.calendar_month_outlined,
                  value: _selectedYearLevel,
                  items: _yearLevels,
                  onChanged: (value) =>
                      setState(() => _selectedYearLevel = value),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Select year level" : null,
                ),
                const SizedBox(height: 16),

                _buildPasswordFormField(
                  controller: _passwordController,
                  label: "Password",
                  obscure: _obscurePassword,
                  toggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter password";
                    if (val.length < 6) return "Password too short";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildPasswordFormField(
                  controller: _cpasswordController,
                  label: "Confirm Password",
                  obscure: _obscureConfirm,
                  toggleVisibility: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Confirm password";
                    if (val != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Checkbox(
                      activeColor: primaryBlue,
                      value: _agreePolicy,
                      onChanged: (val) =>
                          setState(() => _agreePolicy = val ?? false),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "I agree to ",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: "Privacy Policy",
                              style: GoogleFonts.poppins(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Terms of use",
                              style: GoogleFonts.poppins(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signUp,
                    child: Text(
                      _isLoading ? "Creating Account..." : "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      isExpanded: true, // ✅ prevents horizontal overflow
      menuMaxHeight: 300, // ✅ prevents dropdown popup overflow
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
