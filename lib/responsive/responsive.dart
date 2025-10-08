import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    super.key, // Use nullable Key and super.key
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  // Adjusted breakpoints based on standard screen sizes
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop; // Desktop
        } else if (constraints.maxWidth >= 768) {
          return tablet; // Tablet
        } else {
          return mobile; // Mobile
        }
      },
    );
  }
}
