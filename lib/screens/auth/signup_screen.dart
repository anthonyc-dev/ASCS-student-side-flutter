import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/services/authentication.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/widgets/snackbar.dart';
import 'package:my_app/widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _yearLevelController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();

  // NDA acceptance state
  bool _isNDAAccepted = false;

  void _signUp() async {
    // Validate NDA acceptance
    if (!_isNDAAccepted) {
      showSnackBar(
          context, "Please accept the Non-Disclosure Agreement to continue.");
      return;
    }

    String schoolId = _schoolIdController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String program = _programController.text.trim();
    String yearLevel = _yearLevelController.text.trim();
    String password = _passwordController.text.trim();

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

    if (result != "Success") {
      showSnackBar(context, result);
      // Clear input fields on successful registration
      _schoolIdController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _programController.clear();
      _yearLevelController.clear();
      _passwordController.clear();
    } else {
      // Show error message but do NOT navigate
      showSnackBar(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Prevents overflow when keyboard appears
          // reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 2.7,
                child: Image.asset('images/signup.jpeg'),
              ),
              Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust width for desktop-sized screens (e.g., width > 600)
                      double width = constraints.maxWidth;
                      double textFieldWidth = width > 600 ? 400 : width * 0.9;

                      return Column(
                        children: [
                          TextFieldInput(
                            icon: Icons.badge,
                            textEditingController: _schoolIdController,
                            hintText: 'Enter your id number',
                            textInputType: TextInputType.text,
                            width: textFieldWidth,
                          ),
                          TextFieldInput(
                            icon: Icons.person,
                            textEditingController: _firstNameController,
                            hintText: 'Enter Given Name',
                            textInputType: TextInputType.text,
                            width: textFieldWidth,
                          ),
                          TextFieldInput(
                            icon: Icons.person,
                            textEditingController: _lastNameController,
                            hintText: 'Enter Last Name',
                            textInputType: TextInputType.text,
                            width: textFieldWidth,
                          ),
                          TextFieldInput(
                            icon: Icons.email,
                            textEditingController: _emailController,
                            hintText: 'Enter your email',
                            textInputType: TextInputType.emailAddress,
                            width: textFieldWidth,
                          ),
                          TextFieldInput(
                            icon: Icons.call,
                            textEditingController: _phoneController,
                            hintText: 'Enter your phone number',
                            textInputType: TextInputType.text,
                            width: textFieldWidth,
                          ),
                          TextFieldInput(
                            icon: Icons.lock,
                            textEditingController: _passwordController,
                            hintText: 'Enter your password',
                            textInputType: TextInputType.text,
                            isPass: true,
                            width: textFieldWidth,
                          ),
                          TextFieldInput(
                            icon: Icons.lock,
                            textEditingController: _cpasswordController,
                            hintText: 'Confirm your password',
                            textInputType: TextInputType.text,
                            isPass: true,
                            width: textFieldWidth,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
// Non-Disclosure Agreement Acknowledgment
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Non-Disclosure Agreement',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'By creating an account, you agree to maintain confidentiality of all information accessed through this platform.',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _isNDAAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _isNDAAccepted = value ?? false;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            Expanded(
                              child: Text(
                                'I acknowledge and agree to the NDA terms',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Fix Button Overflow
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;
                      double buttonWidth = width > 600 ? 400 : width * 0.9;

                      return SizedBox(
                        // Set width for button
                        child: CustomButton(
                          text: 'Sign Up',
                          icon: Icons.touch_app,
                          color: Colors.blue,
                          onPressed: () {
                            _signUp();
                          },
                          width: buttonWidth,
                        ),
                      );
                    },
                  ),
                  // Sign Up Link
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.outfit(),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "/signin");
                          },
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60), // Extra spacing
              MediaQuery.of(context).viewInsets.bottom == 0
                  ? Image.asset(
                      'images/mobile.png',
                      fit: BoxFit.contain,
                      height: height * 0.15, // Adjust height dynamically
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
