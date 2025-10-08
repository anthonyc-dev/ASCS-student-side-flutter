import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/responsive/responsive.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const CustomDrawer({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    // bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SizedBox(
      width: Responsive.isDesktop(context) ? 230.w : null,
      child: Drawer(
        shape: Responsive.isDesktop(context)
            ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(5), // Rounded edges on mobile
                ),
              ) // No rounding on desktop
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(16), // Rounded edges on mobile
                ),
              ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // DrawerHeader(
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Colors.lightBlueAccent,
            //         Color.fromARGB(221, 134, 70, 70),
            //       ],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //   ),
            //   child: Center(
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           'MicroFlux',
            //           style: GoogleFonts.outfit(
            //             fontSize: 24,
            //             color: Colors.white,
            //           ),
            //         ),
            //         Text(
            //           'There\'s no Exit',
            //           style: GoogleFonts.outfit(
            //             fontSize: 15,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // Profile Section
            const UserAccountsDrawerHeader(
              accountName: Text('John Doe'),
              accountEmail: Text('john.doe@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                ), // Replace with actual image URL or asset
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            _buildDrawerItem(
              Icons.home,
              'Home',
              0,
              context,
              onItemTapped,
              Responsive.isTablet(context) || Responsive.isDesktop(context),
            ),
            _buildDrawerItem(
              Icons.description,
              'Clearance',
              1,
              context,
              onItemTapped,
              Responsive.isTablet(context) || Responsive.isDesktop(context),
            ),
            _buildDrawerItem(
              Icons.edit_document,
              'Requirements',
              2,
              context,
              onItemTapped,
              Responsive.isTablet(context) || Responsive.isDesktop(context),
            ),
            _buildDrawerItem(
              Icons.event,
              'Event',
              '/event',
              context,
              onItemTapped,
              Responsive.isTablet(context) || Responsive.isDesktop(context),
            ),

            _buildDrawerItem(
              Icons.settings,
              'Settings',
              3,
              context,
              onItemTapped,
              Responsive.isTablet(context) || Responsive.isDesktop(context),
            ),
            _buildDrawerItem(
              Icons.event,
              'QrCode',
              '/qrcode',
              context,
              onItemTapped,
              Responsive.isTablet(context) || Responsive.isDesktop(context),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDrawerItem(
  IconData icon,
  String title,
  dynamic
      navigationTarget, // This can be either an index (int) or a route (String)
  BuildContext context,
  Function(int)
      onItemTapped, // Keep the original onItemTapped for index-based navigation
  bool isDesktop,
) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title, style: GoogleFonts.outfit()),
    onTap: () {
      if (!isDesktop) Navigator.pop(context); // Close drawer on mobile

      if (navigationTarget is int) {
        // If navigationTarget is an index, call the onItemTapped function
        onItemTapped(navigationTarget);
      } else if (navigationTarget is String) {
        // If navigationTarget is a route (String), navigate using Navigator.pushNamed
        Navigator.pushNamed(context, navigationTarget);
      }
    },
  );
}
