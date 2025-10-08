import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/services/authentication.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/widgets/snackbar.dart';
import 'package:my_app/widgets/text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    Authentication auth = Authentication();
    String result = await auth.login(
      context: context,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (result != "Success") {
      showSnackBar(context, result);

      _emailController.clear();
      _passwordController.clear();
    } else {
      // Show error message but do NOT navigate
      showSnackBar(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 2.7,
                child: Image.asset('images/login.jpg'),
              ),
              Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust width for desktop-sized screens (e.g., width > 600)
                      double width = constraints.maxWidth;
                      double textFieldWidth = width > 600
                          ? 400
                          : width *
                              0.9; // Use 80% of screen width or 400px for large screens

                      return Column(
                        children: [
                          TextFieldInput(
                            icon: Icons.person,
                            textEditingController: _emailController,
                            hintText: 'Enter your id number',
                            textInputType: TextInputType.text,
                            width: textFieldWidth, // Pass the calculated width
                          ),
                          TextFieldInput(
                            icon: Icons.lock,
                            textEditingController: _passwordController,
                            hintText: 'Enter your password',
                            textInputType: TextInputType.text,
                            isPass: true,
                            width: textFieldWidth, // Pass the calculated width
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;
                      double buttonWidth = width > 600
                          ? 400
                          : width *
                              0.9; // Use 80% of screen width or 400px for large screens

                      return SizedBox(
                        // Set width for button
                        child: CustomButton(
                          text: 'Log In',
                          icon: Icons.touch_app,
                          color: Colors.blue,
                          onPressed: () {
                            _login();
                          },
                          width: buttonWidth,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.outfit(),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "/signup");
                          },
                          child: Text(
                            "Sign Up",
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
              const SizedBox(height: 60),
              MediaQuery.of(context).viewInsets.bottom == 0
                  ? Image.asset(
                      'images/mobile.png',
                      fit: BoxFit.contain,
                      height: height * 0.15,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
