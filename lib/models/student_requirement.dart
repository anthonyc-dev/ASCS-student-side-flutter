class ClearingOfficer {
  final String id;
  final String? schoolId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final String? profileImage;

  ClearingOfficer({
    required this.id,
    this.schoolId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.role,
    this.profileImage,
  });

  factory ClearingOfficer.fromJson(Map<String, dynamic> json) {
    return ClearingOfficer(
      id: json['id'] as String? ?? '',
      schoolId: json['schoolId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }

  String get fullName => '${firstName ?? 'N/A'} ${lastName ?? ''}'.trim();
}

class OfficerRequirement {
  final String id;
  final String userId;
  final String? courseCode;
  final String? courseName;
  final String? yearLevel;
  final String? semester;
  final List<String> requirements;
  final String? department;
  final String? dueDate;
  final String? description;

  OfficerRequirement({
    required this.id,
    required this.userId,
    this.courseCode,
    this.courseName,
    this.yearLevel,
    this.semester,
    required this.requirements,
    this.department,
    this.dueDate,
    this.description,
  });

  factory OfficerRequirement.fromJson(Map<String, dynamic> json) {
    return OfficerRequirement(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      yearLevel: json['yearLevel'] as String?,
      semester: json['semester'] as String?,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'] as List)
          : [],
      department: json['department'] as String?,
      dueDate: json['dueDate'] as String?,
      description: json['description'] as String?,
    );
  }

  String get requirementsString =>
      requirements.isEmpty ? 'N/A' : requirements.join(', ');
}

class StudentRequirement {
  final String id;
  final String studentId;
  final String coId;
  final String requirementId;
  final String? status;
  final String? signedBy;
  final OfficerRequirement? officerRequirement;
  final ClearingOfficer? clearingOfficer;

  StudentRequirement({
    required this.id,
    required this.studentId,
    required this.coId,
    required this.requirementId,
    this.status,
    this.signedBy,
    this.officerRequirement,
    this.clearingOfficer,
  });

  factory StudentRequirement.fromJson(Map<String, dynamic> json) {
    return StudentRequirement(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      coId: json['coId'] as String? ?? '',
      requirementId: json['requirementId'] as String? ?? '',
      status: json['status'] as String?,
      signedBy: json['signedBy'] as String?,
      officerRequirement: json['officerRequirement'] != null
          ? OfficerRequirement.fromJson(
              json['officerRequirement'] as Map<String, dynamic>,
            )
          : null,
      clearingOfficer: json['clearingOfficer'] != null
          ? ClearingOfficer.fromJson(
              json['clearingOfficer'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class InstitutionalRequirement {
  final String id;
  final String? institutionalName;
  final List<String> requirements;
  final String? department;
  final String? description;
  final String? semester;
  final String? deadline;
  final String? postedBy;

  InstitutionalRequirement({
    required this.id,
    this.institutionalName,
    required this.requirements,
    this.department,
    this.description,
    this.semester,
    this.deadline,
    this.postedBy,
  });

  factory InstitutionalRequirement.fromJson(Map<String, dynamic> json) {
    return InstitutionalRequirement(
      id: json['id'] as String? ?? '',
      institutionalName: json['institutionalName'] as String?,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'] as List)
          : [],
      department: json['department'] as String?,
      description: json['description'] as String?,
      semester: json['semester'] as String?,
      deadline: json['deadline'] as String?,
      postedBy: json['postedBy'] as String?,
    );
  }

  String get requirementsString =>
      requirements.isEmpty ? 'N/A' : requirements.join(', ');
}

class StudentInstitutionalRequirement {
  final String id;
  final String studentId;
  final String coId;
  final String requirementId;
  final String? status;
  final String? signedBy;
  final InstitutionalRequirement? institutionalRequirement;
  final ClearingOfficer? clearingOfficer;

  StudentInstitutionalRequirement({
    required this.id,
    required this.studentId,
    required this.coId,
    required this.requirementId,
    this.status,
    this.signedBy,
    this.institutionalRequirement,
    this.clearingOfficer,
  });

  factory StudentInstitutionalRequirement.fromJson(Map<String, dynamic> json) {
    return StudentInstitutionalRequirement(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      coId: json['coId'] as String? ?? '',
      requirementId: json['requirementId'] as String? ?? '',
      status: json['status'] as String?,
      signedBy: json['signedBy'] as String?,
      institutionalRequirement: json['institutionalRequirement'] != null
          ? InstitutionalRequirement.fromJson(
              json['institutionalRequirement'] as Map<String, dynamic>,
            )
          : null,
      clearingOfficer: json['clearingOfficer'] != null
          ? ClearingOfficer.fromJson(
              json['clearingOfficer'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
