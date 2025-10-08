import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const Color selectedBlue = Color(0xFF0A84FF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 6, right: 6),
          child: NavigationBar(
            height: 65,
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemTapped,
            backgroundColor: Colors.transparent,
            indicatorColor:
                colorScheme.secondaryContainer.withValues(alpha: 0.92),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            elevation: 0,
            animationDuration: const Duration(milliseconds: 400),
            destinations: [
              NavigationDestination(
                icon: _AnimatedNavIcon(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  selected: selectedIndex == 0,
                  color:
                      selectedIndex == 0 ? selectedBlue : colorScheme.primary,
                  selectedColor: selectedBlue,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: _AnimatedNavIcon(
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description,
                  selected: selectedIndex == 1,
                  color:
                      selectedIndex == 1 ? selectedBlue : colorScheme.primary,
                  selectedColor: selectedBlue,
                ),
                label: 'Clearances',
              ),
              NavigationDestination(
                icon: _AnimatedNavIcon(
                  icon: Icons.event_available_outlined,
                  selectedIcon: Icons.event_available,
                  selected: selectedIndex == 2,
                  color:
                      selectedIndex == 2 ? selectedBlue : colorScheme.primary,
                  selectedColor: selectedBlue,
                ),
                label: 'Events',
              ),
              NavigationDestination(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.blue.shade200, width: 2), // normal border
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                selectedIcon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.blue, width: 2), // thicker when active
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                label: 'Profile',
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color color;
  final Color? selectedColor;

  const _AnimatedNavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.color,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        selected ? (selectedColor ?? color) : Colors.grey[500]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        vertical: selected ? 2 : 0,
        horizontal: selected ? 2 : 0,
      ),
      decoration: selected
          ? BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Icon(
        selected ? selectedIcon : icon,
        color: iconColor,
        size: selected ? 25 : 25,
        shadows: selected
            ? [
                Shadow(
                  color: iconColor.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}
