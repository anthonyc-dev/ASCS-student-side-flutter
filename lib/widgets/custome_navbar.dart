// lib/widgets/custom_navbar.dart
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GNav(
      rippleColor: Colors.grey[800]!,
      hoverColor: Colors.grey[700]!,
      haptic: true,
      tabBorderRadius: 15,
      tabActiveBorder: Border.all(color: Colors.black, width: 1),
      tabBorder: Border.all(color: Colors.grey, width: 1),
      tabShadow: [
        BoxShadow(color: Colors.grey.withValues(alpha: 0.5), blurRadius: 8),
      ],
      curve: Curves.easeOutExpo,
      duration: const Duration(milliseconds: 900),
      gap: 8,
      color: Colors.grey[800],
      activeColor: Colors.purple,
      iconSize: 24,
      tabBackgroundColor: Colors.purple.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      selectedIndex: selectedIndex, // pass 0 for Home, 1 for Likes, etc.
      onTabChange: onItemTapped,
      tabs: const [
        GButton(
          icon: LineIcons.home,
          text: 'Home',
        ),
        GButton(
          icon: LineIcons.heart,
          text: 'Likes',
        ),
        GButton(
          icon: LineIcons.search,
          text: 'Search',
        ),
        GButton(
          icon: LineIcons.user,
          text: 'Profile',
        ),
      ],
    );
  }
}
