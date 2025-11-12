class Clearance {
  final String id;
  final bool isActive;
  final DateTime startDate;
  final DateTime deadline;
  final DateTime? extendedDeadline;
  final String semesterType;
  final String academicYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  Clearance({
    required this.id,
    required this.isActive,
    required this.startDate,
    required this.deadline,
    this.extendedDeadline,
    required this.semesterType,
    required this.academicYear,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Clearance.fromJson(Map<String, dynamic> json) {
    return Clearance(
      id: json['id'] as String,
      isActive: json['isActive'] as bool,
      startDate: DateTime.parse(json['startDate'] as String),
      deadline: DateTime.parse(json['deadline'] as String),
      extendedDeadline: json['extendedDeadline'] != null
          ? DateTime.parse(json['extendedDeadline'] as String)
          : null,
      semesterType: json['semesterType'] as String,
      academicYear: json['academicYear'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  DateTime get effectiveDeadline => extendedDeadline ?? deadline;
}
