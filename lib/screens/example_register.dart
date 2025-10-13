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

  final List<String> _programs = [
    'BS Computer Science',
    'BS Information Technology',
    'BS Information Systems',
    'BS Software Engineering',
  ];

  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  void _signUp() async {
    String schoolId = _schoolIdController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String program = _selectedProgram ?? '';
    String yearLevel = _selectedYearLevel ?? '';
    String password = _passwordController.text.trim();
    String confirmPassword = _cpasswordController.text.trim();

    if (password != confirmPassword) {
      showSnackBar(context, "Passwords do not match!");
      return;
    }

    if (!_agreePolicy) {
      showSnackBar(context, "Please agree to the Privacy Policy first.");
      return;
    }

    Authentication auth = Authentication();
    String result = await auth.signUp(
      context: context,
      schoolId: schoolId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      program: program,
      yearLevel: yearLevel,
      password: password,
    );

    if (!mounted) return;

    if (result == "Success") {
      showSnackBar(context, "Account created successfully!");
      _clearFields();
    } else {
      showSnackBar(context, result);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title ---
              Text(
                "Let's create your account",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // --- First & Last Name ---
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: "First Name",
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: "Last Name",
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Student ID ---
              _buildTextField(
                controller: _schoolIdController,
                label: "Student ID",
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),

              // --- Email ---
              _buildTextField(
                controller: _emailController,
                label: "E-Mail",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              // --- Phone Number ---
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),

              // --- Program Dropdown ---
              _buildDropdownField(
                label: "Program",
                icon: Icons.list_alt_outlined,
                value: _selectedProgram,
                items: _programs,
                onChanged: (value) {
                  setState(() => _selectedProgram = value);
                },
              ),
              const SizedBox(height: 16),

              // --- Year Level Dropdown ---
              _buildDropdownField(
                label: "Year Level",
                icon: Icons.calendar_month_outlined,
                value: _selectedYearLevel,
                items: _yearLevels,
                onChanged: (value) {
                  setState(() => _selectedYearLevel = value);
                },
              ),
              const SizedBox(height: 16),

              // --- Password ---
              _buildPasswordField(
                controller: _passwordController,
                label: "Password",
                obscure: _obscurePassword,
                toggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 20),

              // --- Confirm Password ---
              _buildPasswordField(
                controller: _cpasswordController,
                label: "Confirm Password",
                obscure: _obscureConfirm,
                toggleVisibility: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 20),

              // --- Terms and Conditions ---
              Row(
                children: [
                  Checkbox(
                    activeColor: primaryBlue,
                    value: _agreePolicy,
                    onChanged: (val) {
                      setState(() => _agreePolicy = val ?? false);
                    },
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

              // --- Create Account Button ---
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
                  onPressed: _signUp,
                  child: Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Text Field Builder ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
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

  // --- Dropdown Field Builder ---
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
      initialValue: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // --- Password Field Builder ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
