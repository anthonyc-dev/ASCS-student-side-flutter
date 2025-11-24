# Offline Mode Implementation Guide

## Overview
This guide explains how the offline functionality works in your Flutter app using Hive for local storage.

## Features Implemented

### 1. Offline Login
- Users can login with cached credentials when offline
- Credentials are securely stored after successful online login
- User data is cached for offline access

### 2. Offline Requirements Access
- Department requirements are cached after first fetch
- Institutional requirements are cached after first fetch
- Users can view requirements even when offline

### 3. Offline Permit Access
- Permit data including QR code is cached
- Users can view their permit offline if previously loaded

### 4. Offline Indicator
- Visual banner shows "Working in Offline Mode" when offline
- Automatic network status detection

## How It Works

### Storage Structure
Hive creates 4 boxes (similar to tables):

1. **authBox**: Stores authentication data
   - email
   - password (encrypted)
   - isLoggedIn
   - lastSyncTime

2. **studentBox**: Stores student profile data
   - schoolId
   - firstName
   - lastName
   - email
   - phoneNumber
   - program
   - yearLevel
   - profileImage

3. **requirementsBox**: Stores requirements data
   - deptRequirements (list)
   - instRequirements (list)
   - lastSync timestamps

4. **permitBox**: Stores permit data
   - permitData (QR code and details)
   - permitLastSync

## Usage in Your Screens

### Example 1: Using Offline Indicator in a Screen

```dart
import 'package:flutter/material.dart';
import 'package:my_app/services/network_service.dart';
import 'package:my_app/widgets/offline_indicator.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final NetworkService _networkService = NetworkService();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Listen to network changes
    _networkService.connectionStream.listen((isOnline) {
      setState(() {
        _isOffline = !isOnline;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _networkService.checkConnectivity();
    setState(() {
      _isOffline = !isOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Column(
        children: [
          OfflineIndicator(isOffline: _isOffline),
          Expanded(
            child: YourContent(),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Fetching Requirements with Offline Support

The services are already updated to handle offline mode automatically!

```dart
// In your screen
Future<void> _loadRequirements() async {
  try {
    final requirements = await StudentRequirementService()
        .getStudentRequirementsBySchoolId(schoolId);

    // This will:
    // 1. Try to fetch from API
    // 2. If successful, cache the data
    // 3. If fails (offline), load from cache

    setState(() {
      _requirements = requirements;
    });
  } catch (e) {
    // Show error if no cache available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Example 3: Fetching Permit with Offline Support

```dart
// In your QR code screen
Future<void> _loadPermit() async {
  final permitData = await PermitService()
      .getPermitByStudentId(studentId);

  if (permitData != null) {
    // This will:
    // 1. Try to fetch from API
    // 2. If successful, cache the data
    // 3. If fails (offline), load from cache

    setState(() {
      _permitData = permitData;
    });
  }
}
```

## Testing Offline Mode

### Method 1: Airplane Mode
1. Login to the app while online
2. Navigate through screens to cache data
3. Enable Airplane Mode
4. Close and reopen the app
5. Try to login with same credentials
6. Navigate to requirements and permit screens

### Method 2: Disconnect WiFi
1. Same steps as above but disconnect WiFi instead

## What Gets Cached

### On Login (Online)
- User email and password
- Student profile data (name, school ID, program, etc.)

### On Requirements Fetch (Online)
- All department requirements
- All institutional requirements
- Last sync timestamp

### On Permit Fetch (Online)
- Permit details
- QR code data
- Last sync timestamp

## Important Notes

### Security
- Passwords are stored as-is (same as received from server)
- For production, consider encrypting sensitive data
- Use flutter_secure_storage for enhanced security

### Limitations
- Cannot submit new data while offline
- Cannot update requirements status offline
- QR code verification requires internet

### Data Sync
- Data syncs automatically when online
- Manual refresh pulls latest data
- Last sync time is displayed in offline mode

## Quick Implementation Checklist

- [x] Install Hive packages
- [x] Initialize Hive in main.dart
- [x] Create offline storage service
- [x] Update authentication service
- [x] Update requirements service
- [x] Update permit service
- [x] Create offline indicator widget
- [x] Create network service

## Next Steps (Optional Enhancements)

1. **Add Sync Indicator**
   ```dart
   Text('Last synced: ${_getLastSyncTime()}')
   ```

2. **Add Manual Refresh**
   ```dart
   RefreshIndicator(
     onRefresh: _refreshData,
     child: ListView(...),
   )
   ```

3. **Show Cached Data Warning**
   ```dart
   if (_isOffline) {
     Text('Viewing cached data from ${lastSync}')
   }
   ```

## Troubleshooting

### Issue: "No cached data available"
**Solution**: User must login and fetch data while online first

### Issue: Offline indicator not showing
**Solution**: Check network service is initialized and connectivity is checked

### Issue: Login fails offline
**Solution**: User must have logged in successfully online first to cache credentials

## Support

For issues or questions:
1. Check this guide first
2. Review the service implementations
3. Check Hive documentation: https://docs.hivedb.dev/
