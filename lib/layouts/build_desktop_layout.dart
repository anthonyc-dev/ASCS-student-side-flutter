import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_app/responsive/responsive.dart';
import 'package:my_app/widgets/custom_drawer.dart';

class BuildDesktopLayout extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<Widget> screens;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  BuildDesktopLayout({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    // bool isDesktop =
    //     MediaQuery.of(context).size.width > 800; // Detects large screens

    return Scaffold(
      key: scaffoldKey, // Assign scaffold key for drawer control
      appBar: AppBar(
        title: Responsive.isDesktop(context)
            ? Image.asset(
                'images/web.png', // Replace with your image path
                height: 150, // Adjust height as needed
                width: 150, // Optional: Adjust width
                fit: BoxFit
                    .contain, // Ensures the image maintains its aspect ratio
              )
            : null,
        elevation: Responsive.isDesktop(context) ? 4.0 : 0.0,
        shadowColor: Responsive.isDesktop(context)
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.transparent,

        // Hide default drawer button on large screens
        actions: [
          if (Responsive.isDesktop(context))
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('Home button pressed');
                }
              },
              child: const Text(
                'Home',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          if (Responsive.isDesktop(context))
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('About button pressed');
                }
              },
              child: const Text(
                'About',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          if (Responsive.isDesktop(context))
            TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print('Contact button pressed');
                }
                onItemTapped(2);
              },
              child: const Text(
                'Contact',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
        ],
      ),
      drawer: !Responsive.isDesktop(context)
          // Only show Drawer on small screens Mobile size
          ? CustomDrawer(onItemTapped: onItemTapped)
          : null, // Drawer should be null for wide screens

      body: Row(
        children: [
          if (Responsive.isDesktop(
            context,
          )) // Show permanent Drawer only on large screens Desktop size
            CustomDrawer(onItemTapped: onItemTapped),
          Expanded(child: screens[selectedIndex]), // Display selected screen
        ],
      ),
    );
  }
}
