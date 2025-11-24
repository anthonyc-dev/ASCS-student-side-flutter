import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineStorageService {
  static const String _authBoxName = 'authBox';
  static const String _requirementsBoxName = 'requirementsBox';
  static const String _permitBoxName = 'permitBox';

  static Box? _authBox;
  static Box? _requirementsBox;
  static Box? _permitBox;

  // Initialize all Hive boxes
  static Future<void> init() async {
    _authBox = await Hive.openBox(_authBoxName);
    _requirementsBox = await Hive.openBox(_requirementsBoxName);
    _permitBox = await Hive.openBox(_permitBoxName);
  }

  // ========== AUTH BOX ==========
  // Save auth data
  static Future<void> saveAuthData({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? userRole,
    String? email,
    String? firstName,
    String? schoolId,
  }) async {
    if (_authBox == null) await init();

    if (accessToken != null) {
      await _authBox!.put('accessToken', accessToken);
    }
    if (refreshToken != null) {
      await _authBox!.put('refreshToken', refreshToken);
    }
    if (userId != null) {
      await _authBox!.put('userId', userId);
    }
    if (userRole != null) {
      await _authBox!.put('userRole', userRole);
    }
    if (email != null) {
      await _authBox!.put('email', email);
    }
    if (firstName != null) {
      await _authBox!.put('firstName', firstName);
    }
    if (schoolId != null) {
      await _authBox!.put('schoolId', schoolId);
    }
  }

  // Get auth data
  static String? getAccessToken() => _authBox?.get('accessToken');
  static String? getRefreshToken() => _authBox?.get('refreshToken');
  static String? getUserId() => _authBox?.get('userId');
  static String? getUserRole() => _authBox?.get('userRole');
  static String? getEmail() => _authBox?.get('email');
  static String? getFirstName() => _authBox?.get('firstName');
  static String? getSchoolId() => _authBox?.get('schoolId');

  // Check if user is logged in (offline)
  static bool isLoggedInOffline() {
    return _authBox?.get('schoolId') != null && _authBox?.get('email') != null;
  }

  // Clear auth data
  static Future<void> clearAuthData() async {
    if (_authBox == null) await init();
    await _authBox!.clear();
  }

  // ========== REQUIREMENTS BOX ==========
  // Save department requirements
  static Future<void> saveDepartmentRequirements(
    String schoolId,
    List<Map<String, dynamic>> requirements,
  ) async {
    if (_requirementsBox == null) await init();
    await _requirementsBox!.put('dept_$schoolId', jsonEncode(requirements));
    await _requirementsBox!
        .put('dept_${schoolId}_timestamp', DateTime.now().toIso8601String());
  }

  // Get department requirements
  static List<Map<String, dynamic>>? getDepartmentRequirements(
      String schoolId) {
    if (_requirementsBox == null) return null;
    final data = _requirementsBox!.get('dept_$schoolId');
    if (data == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(data as String);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  // Save institutional requirements
  static Future<void> saveInstitutionalRequirements(
    String studentId,
    List<Map<String, dynamic>> requirements,
  ) async {
    if (_requirementsBox == null) await init();
    await _requirementsBox!.put('inst_$studentId', jsonEncode(requirements));
    await _requirementsBox!
        .put('inst_${studentId}_timestamp', DateTime.now().toIso8601String());
  }

  // Get institutional requirements
  static List<Map<String, dynamic>>? getInstitutionalRequirements(
      String studentId) {
    if (_requirementsBox == null) return null;
    final data = _requirementsBox!.get('inst_$studentId');
    if (data == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(data as String);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  // ========== PERMIT BOX ==========
  // Save permit data
  static Future<void> savePermitData(
    String studentId,
    Map<String, dynamic> permitData,
  ) async {
    if (_permitBox == null) await init();
    await _permitBox!.put('permit_$studentId', jsonEncode(permitData));
    await _permitBox!
        .put('permit_${studentId}_timestamp', DateTime.now().toIso8601String());
  }

  // Get permit data
  static Map<String, dynamic>? getPermitData(String studentId) {
    if (_permitBox == null) return null;
    final data = _permitBox!.get('permit_$studentId');
    if (data == null) return null;
    try {
      return jsonDecode(data as String) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Clear all offline data
  static Future<void> clearAll() async {
    if (_authBox == null) await init();
    await _authBox!.clear();
    await _requirementsBox!.clear();
    await _permitBox!.clear();
  }
}
