import 'package:flutter/material.dart';
import 'package:my_app/widgets/bottom_navigation.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:my_app/screens/nonifiocation.dart';
// import 'package:my_app/widgets/menu_anchor.dart';

class BuildMobileLayout extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<Widget> screens;

  const BuildMobileLayout({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   title: Row(
      //     children: [
      //       CircleAvatar(
      //         radius: 20,
      //         backgroundColor: Colors.grey[200],
      //         backgroundImage: const NetworkImage(
      //             'https://randomuser.me/api/portraits/men/32.jpg'),
      //         // child: const Icon(
      //         //   Icons.person,
      //         //   color: Colors.grey,
      //         //   size: 24,
      //         // ),
      //       ),
      //       const SizedBox(width: 12),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             'John Doe',
      //             style: GoogleFonts.outfit(
      //               fontSize: 16,
      //               fontWeight: FontWeight.w600,
      //               color: Colors.black87,
      //             ),
      //           ),
      //           Text(
      //             'Premium Member',
      //             style: GoogleFonts.outfit(
      //               fontSize: 12,
      //               color: Colors.grey[600],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     Row(
      //       children: [
      //         IconButton(
      //           icon: const Icon(
      //             Icons.notifications_outlined,
      //             color: Colors.black87,
      //           ),
      //           onPressed: () {
      //             Navigator.of(context).push(
      //               PageRouteBuilder(
      //                 pageBuilder: (context, animation, secondaryAnimation) =>
      //                     const NotificationScreen(),
      //                 transitionsBuilder:
      //                     (context, animation, secondaryAnimation, child) {
      //                   const begin = Offset(1.0, 0.0);
      //                   const end = Offset.zero;
      //                   const curve = Curves.ease;
      //                   final tween = Tween(begin: begin, end: end)
      //                       .chain(CurveTween(curve: curve));
      //                   return SlideTransition(
      //                     position: animation.drive(tween),
      //                     child: child,
      //                   );
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //         IconButton(
      //           icon: const Icon(
      //             Icons.share,
      //             color: Colors.black87,
      //           ),
      //           onPressed: () {
      //             showDialog(
      //               context: context,
      //               builder: (context) => AlertDialog(
      //                 title: const Text('Share'),
      //                 content: const Text('Share button clicked!'),
      //                 actions: [
      //                   TextButton(
      //                     onPressed: () => Navigator.of(context).pop(),
      //                     child: const Text('OK'),
      //                   ),
      //                 ],
      //               ),
      //             );
      //           },
      //         ),
      //         MenuAnchorWidget(
      //           onProfile: () {
      //             // Navigator.pushNamed(context, '/profile');
      //             if (kDebugMode) {
      //               print("Profile clicked");
      //             }
      //           },
      //           onSettings: () {
      //             // Navigator.pushNamed(context, '/settings');
      //             if (kDebugMode) {
      //               print("Settings clicked");
      //             }
      //           },
      //           onNotification: () {
      //             // Navigator.pushNamed(context, '/notif');
      //             if (kDebugMode) {
      //               print("Notification clicked");
      //             }
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
      body: screens[selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
