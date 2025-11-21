class Student {
  final String? id;
  final String schoolId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String program;
  final String yearLevel;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.schoolId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.program,
    required this.yearLevel,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? json['id'],
      schoolId: json['schoolId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      program: json['program'] ?? '',
      yearLevel: json['yearLevel'] ?? '',
      profileImage: json['profileImage'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'schoolId': schoolId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'program': program,
      'yearLevel': yearLevel,
    };
  }

  String get fullName => '$firstName $lastName';
}
