class ClearingOfficer {
  final String id;
  final String schoolId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final String? profileImage;

  ClearingOfficer({
    required this.id,
    required this.schoolId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImage,
  });

  factory ClearingOfficer.fromJson(Map<String, dynamic> json) {
    return ClearingOfficer(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';
}

class OfficerRequirement {
  final String id;
  final String userId;
  final String courseCode;
  final String courseName;
  final String yearLevel;
  final String semester;
  final List<String> requirements;
  final String department;
  final String? dueDate;
  final String description;

  OfficerRequirement({
    required this.id,
    required this.userId,
    required this.courseCode,
    required this.courseName,
    required this.yearLevel,
    required this.semester,
    required this.requirements,
    required this.department,
    this.dueDate,
    required this.description,
  });

  factory OfficerRequirement.fromJson(Map<String, dynamic> json) {
    return OfficerRequirement(
      id: json['id'] as String,
      userId: json['userId'] as String,
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      yearLevel: json['yearLevel'] as String,
      semester: json['semester'] as String,
      requirements: List<String>.from(json['requirements'] as List),
      department: json['department'] as String,
      dueDate: json['dueDate'] as String?,
      description: json['description'] as String,
    );
  }

  String get requirementsString => requirements.join(', ');
}

class StudentRequirement {
  final String id;
  final String studentId;
  final String coId;
  final String requirementId;
  final String status;
  final String signedBy;
  final OfficerRequirement officerRequirement;
  final ClearingOfficer clearingOfficer;

  StudentRequirement({
    required this.id,
    required this.studentId,
    required this.coId,
    required this.requirementId,
    required this.status,
    required this.signedBy,
    required this.officerRequirement,
    required this.clearingOfficer,
  });

  factory StudentRequirement.fromJson(Map<String, dynamic> json) {
    return StudentRequirement(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      coId: json['coId'] as String,
      requirementId: json['requirementId'] as String,
      status: json['status'] as String,
      signedBy: json['signedBy'] as String,
      officerRequirement: OfficerRequirement.fromJson(
        json['officerRequirement'] as Map<String, dynamic>,
      ),
      clearingOfficer: ClearingOfficer.fromJson(
        json['clearingOfficer'] as Map<String, dynamic>,
      ),
    );
  }
}

class InstitutionalRequirement {
  final String id;
  final String institutionalName;
  final List<String> requirements;
  final String department;
  final String description;
  final String semester;
  final String? deadline;
  final String postedBy;

  InstitutionalRequirement({
    required this.id,
    required this.institutionalName,
    required this.requirements,
    required this.department,
    required this.description,
    required this.semester,
    this.deadline,
    required this.postedBy,
  });

  factory InstitutionalRequirement.fromJson(Map<String, dynamic> json) {
    return InstitutionalRequirement(
      id: json['id'] as String,
      institutionalName: json['institutionalName'] as String,
      requirements: List<String>.from(json['requirements'] as List),
      department: json['department'] as String,
      description: json['description'] as String,
      semester: json['semester'] as String,
      deadline: json['deadline'] as String?,
      postedBy: json['postedBy'] as String,
    );
  }

  String get requirementsString => requirements.join(', ');
}

class StudentInstitutionalRequirement {
  final String id;
  final String studentId;
  final String coId;
  final String requirementId;
  final String status;
  final String signedBy;
  final InstitutionalRequirement institutionalRequirement;
  final ClearingOfficer clearingOfficer;

  StudentInstitutionalRequirement({
    required this.id,
    required this.studentId,
    required this.coId,
    required this.requirementId,
    required this.status,
    required this.signedBy,
    required this.institutionalRequirement,
    required this.clearingOfficer,
  });

  factory StudentInstitutionalRequirement.fromJson(Map<String, dynamic> json) {
    return StudentInstitutionalRequirement(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      coId: json['coId'] as String,
      requirementId: json['requirementId'] as String,
      status: json['status'] as String,
      signedBy: json['signedBy'] as String,
      institutionalRequirement: InstitutionalRequirement.fromJson(
        json['institutionalRequirement'] as Map<String, dynamic>,
      ),
      clearingOfficer: ClearingOfficer.fromJson(
        json['clearingOfficer'] as Map<String, dynamic>,
      ),
    );
  }
}
