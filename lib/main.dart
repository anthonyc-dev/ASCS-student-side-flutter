import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_app/screens/auth/sign_in_screen.dart';
import 'package:my_app/screens/auth/signup_screen.dart';
import 'package:my_app/screens/dashboard.dart';
import 'package:my_app/screens/dept_clearance.dart';
import 'package:my_app/screens/events.dart';
import 'package:my_app/screens/example_login.dart';
import 'package:my_app/screens/example_register.dart';
import 'package:my_app/screens/home_dashboard.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/nonifiocation.dart';
import 'package:my_app/screens/profile_screen.dart';
import 'package:my_app/screens/qr_code.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/utils/screen_size.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

// onboarding remove if there have error
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.seenOnboarding});

// onboarding remove if there have error
  final bool seenOnboarding;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Base size for UI design (adjust if needed)
      designSize: ScreenSizeUtil().getDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Automated Student Clearance System',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Outfit'),
              bodyMedium: TextStyle(fontFamily: 'Outfit'),
              displayLarge: TextStyle(fontFamily: 'Outfit'),
              displayMedium: TextStyle(fontFamily: 'Outfit'),
              // Add other styles here as needed
            ),
          ),
          initialRoute: seenOnboarding ? '/login' : '/onboarding', //signin
          routes: {
            '/homeDashboard': (context) => const HomeDashboard(),
            '/home': (context) => const HomeScreen(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/event': (context) => const EventsPage(),
            '/qrcode': (context) => const QrCode(),
            '/notif': (context) => const NotificationScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/profile': (context) => const StudentProfileScreen(),
            '/clearance': (context) => const DeptClearance(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
          },
        );
      },
    );
  }
}
