import 'package:flutter/material.dart';

class MenuAnchorWidget extends StatelessWidget {
  final void Function()? onProfile;
  final void Function()? onSettings;
  final void Function()? onNotification;

  const MenuAnchorWidget({
    Key? key,
    this.onProfile,
    this.onSettings,
    this.onNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      color: Colors.black,
      onSelected: (value) {
        switch (value) {
          case 0:
            if (onProfile != null) {
              onProfile!();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Share'),
                  content: const Text('Share button clicked!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
            break;
          case 1:
            if (onSettings != null) {
              onSettings!();
            } else {
              Navigator.pushNamed(context, '/settings');
            }
            break;
          case 2:
            if (onNotification != null) {
              onNotification!();
            } else {
              Navigator.pushNamed(context, '/notif');
            }
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.white),
              SizedBox(width: 8),
              Text('Share', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.white),
              SizedBox(width: 8),
              Text('Settings', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.white),
              SizedBox(width: 8),
              Text('Notification', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
