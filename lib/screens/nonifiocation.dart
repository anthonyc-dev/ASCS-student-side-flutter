import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _deleteNotification(
      BuildContext context, String? notificationId) async {
    if (notificationId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification deleted',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete notification',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(includeMetadataChanges: false),
        builder: (context, snapshot) {
          final notificationCount =
              snapshot.hasData ? snapshot.data!.docs.length : 0;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Notifications",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (notificationCount > 0) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$notificationCount',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: _buildBody(context, snapshot),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Error loading notifications: ${snapshot.error}',
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    final notifications = snapshot.data?.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList() ??
        [];

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications here when you get them',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notifications.map((notification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NotificationCard(
                notification: notification,
                onDelete: () => _deleteNotification(context, notification.id),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  // Helper method to determine icon and color based on notification type
  Map<String, dynamic> _getNotificationStyle() {
    final title = notification.title.toLowerCase();
    final message = notification.message.toLowerCase();

    if (title.contains('deadline') ||
        title.contains('urgent') ||
        message.contains('deadline') ||
        message.contains('urgent')) {
      return {
        'icon': Icons.access_alarm_rounded,
        'color': Colors.orange,
        'isUrgent': true,
      };
    } else if (title.contains('cleared') ||
        title.contains('approved') ||
        message.contains('cleared') ||
        message.contains('approved')) {
      return {
        'icon': Icons.check_circle_rounded,
        'color': Colors.green,
        'isUrgent': false,
      };
    } else if (title.contains('requirement') ||
        title.contains('created') ||
        message.contains('requirement')) {
      return {
        'icon': Icons.school_rounded,
        'color': Colors.blue,
        'isUrgent': false,
      };
    } else if (title.contains('reject') ||
        title.contains('denied') ||
        message.contains('reject') ||
        message.contains('denied')) {
      return {
        'icon': Icons.cancel_rounded,
        'color': Colors.red,
        'isUrgent': false,
      };
    } else if (title.contains('pending') || message.contains('pending')) {
      return {
        'icon': Icons.pending_rounded,
        'color': Colors.amber,
        'isUrgent': false,
      };
    } else {
      return {
        'icon': Icons.notifications_rounded,
        'color': Colors.blueAccent,
        'isUrgent': false,
      };
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Notification',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this notification?',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getNotificationStyle();
    final IconData icon = style['icon'];
    final Color iconColor = style['color'];
    final bool isUrgent = style['isUrgent'];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white.withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isUrgent
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isUrgent
                ? Colors.orange.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28.0,
            ),
          ),
          const SizedBox(width: 16),

          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: GoogleFonts.outfit(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'URGENT',
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notification.getTimeAgo(),
                      style: GoogleFonts.lato(
                        fontSize: 13.0,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action Button - Delete
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red[400],
                size: 22,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
