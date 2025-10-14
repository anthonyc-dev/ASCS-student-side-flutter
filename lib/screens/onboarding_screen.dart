import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:my_app/screens/example_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Function to set onboarding as seen
  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    // Check if widget is still in the widget tree
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
            title: "Welcome",
            body:
                "Easily manage and track your student clearance process in one app. No more long lines or paperwork!",
            image: Center(
              child: Image.asset(
                "images/onboarding/3.png",
                height: 500,
                width: 500,
                fit: BoxFit.contain,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Poppins', // You can use a custom font
              ),
              bodyTextStyle: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5, // line spacing
              ),
              pageColor: Colors.white, // Background color of this page
              imagePadding: EdgeInsets.all(24), // Padding around the image
              contentMargin:
                  EdgeInsets.symmetric(horizontal: 16), // Margin around text
              titlePadding:
                  EdgeInsets.only(top: 30, bottom: 20), // Padding around title
            ),
          ),
          PageViewModel(
            title: "Track Your Clearance",
            body:
                "Monitor your clearance progress in real-time. See which departments have approved your documents.",
            image: Center(
              child: Image.asset(
                "images/onboarding/1.png",
                height: 500,
                width: 500,
                fit: BoxFit.contain,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Poppins', // You can use a custom font
              ),
              bodyTextStyle: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5, // line spacing
              ),
              pageColor: Colors.white, // Background color of this page
              imagePadding: EdgeInsets.all(24), // Padding around the image
              contentMargin:
                  EdgeInsets.symmetric(horizontal: 16), // Margin around text
              titlePadding:
                  EdgeInsets.only(top: 30, bottom: 20), // Padding around title
            ),
          ),
          PageViewModel(
            title: "Get Notifications & Alerts",
            body:
                "Receive instant updates when your clearance is approved or if additional documents are needed.",
            image: Center(
              child: Image.asset(
                "images/onboarding/2.png",
                height: 500,
                width: 500,
                fit: BoxFit.contain,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Poppins', // You can use a custom font
              ),
              bodyTextStyle: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5, // line spacing
              ),
              pageColor: Colors.white, // Background color of this page
              imagePadding: EdgeInsets.all(24), // Padding around the image
              contentMargin:
                  EdgeInsets.symmetric(horizontal: 16), // Margin around text
              titlePadding:
                  EdgeInsets.only(top: 30, bottom: 20), // Padding around title
            ),
          ),
        ],
        onDone: _completeOnboarding,
        showSkipButton: true,
        skip: const Text("Skip",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        next: const Icon(Icons.arrow_forward, color: Colors.black, size: 24),
        done: const Text("Done",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        dotsDecorator: DotsDecorator(
          size: const Size(10, 10), // Inactive dot size
          color: Colors.grey, // Inactive dot color
          activeSize: const Size(20, 10), // Active dot size
          activeColor: Colors.blue, // Active dot color
          activeShape: RoundedRectangleBorder(
            // Shape of active dot
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
