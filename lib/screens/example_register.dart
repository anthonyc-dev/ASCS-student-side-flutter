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
    if (!_formKey.currentState!.validate()) {
      // Form validation failed
      showSnackBar(context, "Please fix the errors in the form.");
      return;
    }

    if (!_agreePolicy) {
      showSnackBar(context, "Please agree to the Privacy Policy first.");
      return;
    }

    setState(() => _isLoading = true);

    // Show Cupertino loading dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CupertinoAlertDialog(
        title: Text("Logging In"),
        content: Padding(
          padding: EdgeInsets.only(top: 12),
          child: CupertinoActivityIndicator(radius: 14),
        ),
      ),
    );

    try {
      Authentication auth = Authentication();
      String result = await auth.signUp(
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

      // ✅ Always close dialog safely
      // if (!mounted) return;
      // if (Navigator.canPop(context)) {
      //   Navigator.of(context, rootNavigator: true).pop();
      // }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result == "Success") {
        showSnackBar(context, "Account created successfully!");
        _clearFields();

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login', // Your home route
          (route) => false, // Remove all previous routes
        );
      } else {
        showSnackBar(context, result);
      }
    } catch (error) {
      // ✅ Handle unexpected exceptions
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      setState(() => _isLoading = false);
      showSnackBar(context, "Unexpected error: $error");
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
            key: _formKey, // Assign form key
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

                // --- First & Last Name ---
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _firstNameController,
                        label: "First Name",
                        icon: Icons.person_outline,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Enter first name";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _lastNameController,
                        label: "Last Name",
                        icon: Icons.person_outline,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Enter last name";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Student ID ---
                _buildTextFormField(
                  controller: _schoolIdController,
                  label: "Student ID",
                  icon: Icons.badge_outlined,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter student ID";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Email ---
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

                // --- Phone Number ---
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

                // --- Program Dropdown ---
                _buildDropdownFormField(
                  label: "Program",
                  icon: Icons.list_alt_outlined,
                  value: _selectedProgram,
                  items: _programs,
                  onChanged: (value) =>
                      setState(() => _selectedProgram = value),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Select program";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Year Level Dropdown ---
                _buildDropdownFormField(
                  label: "Year Level",
                  icon: Icons.calendar_month_outlined,
                  value: _selectedYearLevel,
                  items: _yearLevels,
                  onChanged: (value) =>
                      setState(() => _selectedYearLevel = value),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Select year level";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Password ---
                _buildPasswordFormField(
                  controller: _passwordController,
                  label: "Password",
                  obscure: _obscurePassword,
                  toggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter password";
                    if (val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Confirm Password ---
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

                // --- Terms Checkbox ---
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

                // --- Sign Up Button ---
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

  // --- TextFormField Builder ---
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

  // --- DropdownFormField Builder ---
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
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // --- PasswordFormField Builder ---
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
