import 'package:intl/intl.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Format date for display: "Nov 18, 2025 • 12:00 AM"
  String get formattedDate {
    return DateFormat('MMM d, yyyy • h:mm a').format(eventDate);
  }

  // Convert to the map format used in the EventCard widget
  Map<String, dynamic> toEventCardMap() {
    return {
      'title': title,
      'description': description,
      'date': formattedDate,
      'venue': location,
      'eventDate': eventDate, // Include the DateTime object for calendar
    };
  }
}
