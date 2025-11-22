# Image Upload Troubleshooting Guide

## Problem Analysis

Your Flutter code looks correct. The issue is likely on the **backend** side. Here are the common issues:

### Backend Issues:

1. **Body Parser Middleware Conflict**: `body-parser` middleware is consuming the request body before `multer` can process it
2. **CORS Headers**: File uploads need proper CORS headers
3. **Route Registration**: The route might not be properly registered

---

## Backend Fixes

### Fix 1: Remove or Conditionally Apply Body Parser

**Problem**: `bodyParser.urlencoded()` and `bodyParser.json()` consume the request stream, preventing multer from reading the file.

**Solution**: Apply body parser AFTER file upload routes, or exclude file upload routes from body parser.

#### Option A: Reorder Middleware (Recommended)

```typescript
// In your main server file (app.ts or index.ts)

import express, { Application, Request, Response } from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
// Remove these lines:
// import bodyParser from "body-parser";

const app: Application = express();

// Middleware
app.use(cookieParser());
app.use(
  cors({
    origin: "*",
    methods: "GET,POST,PUT,DELETE",
    allowedHeaders: "Content-Type, Authorization",
  })
);

// IMPORTANT: Use express built-in parsers AFTER defining routes that use multer
// Or use them conditionally

// Register routes that use multer FIRST (before body parsers)
app.use("/student", studentRoutes);  // This has the multer route

// THEN apply body parsers for other routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Other routes that need body parsing
app.use("/auth", clearingOfficer);
app.use("/qr-code", qrCodeRoutes);
// ... rest of routes
```

#### Option B: Conditional Body Parser Middleware

```typescript
// Create a middleware that skips body parsing for file upload routes
app.use((req, res, next) => {
  // Skip body parsing for file upload endpoints
  if (req.path.includes('/updateStudentProfileImage')) {
    return next();
  }

  // Apply body parsing for other routes
  express.json()(req, res, (err) => {
    if (err) return next(err);
    express.urlencoded({ extended: true })(req, res, next);
  });
});
```

---

### Fix 2: Update CORS Configuration

```typescript
// More specific CORS for file uploads
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "Accept",
      "Origin",
      "X-Requested-With"
    ],
    exposedHeaders: ["Content-Type"],
    credentials: false, // Set to false when using origin: "*"
  })
);
```

---

### Fix 3: Verify Multer Route Configuration

Make sure your route is properly set up:

```typescript
// In your student route file
import { Router } from "express";
import { upload } from "../middleware/upload"; // Your multer config
import { updateStudentProfileImage } from "../controllers/studentController";

const router = Router();

// Make sure this route is defined
router.put(
  "/updateStudentProfileImage/:schoolId",
  upload.single("profileImage"), // This must come FIRST
  updateStudentProfileImage
);

export default router;
```

---

### Fix 4: Enhanced Error Handling in Controller

```typescript
export const updateStudentProfileImage = async (
  req: Request,
  res: Response
) => {
  try {
    console.log("=== Update Profile Image Request ===");
    console.log("School ID:", req.params.schoolId);
    console.log("File received:", req.file ? "YES" : "NO");
    console.log("File details:", req.file);
    console.log("Headers:", req.headers);
    console.log("====================================");

    const { schoolId } = req.params;

    // Check if file was uploaded
    if (!req.file) {
      console.error("No file in request");
      res.status(400).json({
        message: "No profile image file provided",
        receivedHeaders: req.headers["content-type"],
        receivedBody: req.body
      });
      return;
    }

    // Fetch the existing student
    const existingStudent = await prisma.student.findUnique({
      where: { schoolId },
    });

    if (!existingStudent) {
      res.status(404).json({ message: "Student not found" });
      return;
    }

    // Upload new profile image
    let newProfileImageUrl: string;
    try {
      newProfileImageUrl = await uploadImageToCloudinary(
        req.file,
        "student-profile"
      );
      console.log("Cloudinary upload successful:", newProfileImageUrl);
    } catch (uploadError) {
      console.error("Profile image upload failed:", uploadError);
      res.status(500).json({
        message: "Failed to upload profile image",
        error: uploadError instanceof Error ? uploadError.message : String(uploadError)
      });
      return;
    }

    // Delete old profile image if it exists
    if (existingStudent.profileImage) {
      try {
        await deleteImageFromCloudinary(existingStudent.profileImage);
        console.log("Old profile image deleted");
      } catch (deleteError) {
        console.warn("Failed to delete old profile image:", deleteError);
      }
    }

    // Update only the profileImage field in the database
    const updatedStudent = await prisma.student.update({
      where: { schoolId },
      data: {
        profileImage: newProfileImageUrl,
        updatedAt: new Date(),
      },
    });

    console.log("Profile image updated successfully");
    res.json({
      message: "Profile image updated successfully",
      updatedStudent,
    });
  } catch (error: any) {
    console.error("Error updating profile image:", error);
    res.status(500).json({
      message: "Server error",
      error: error.message || String(error)
    });
    return;
  }
};
```

---

## Flutter Side - Enhanced Logging

Update your Flutter service with even more detailed logging (already looks good, but here's an enhanced version):

```dart
Future<Student> uploadProfileImage(
    String schoolId, File imageFile, Student currentStudent) async {
  try {
    final cleanSchoolId = schoolId.trim();
    var url = Uri.parse("$apiUrl/student/updateStudentProfileImage/$cleanSchoolId");

    print('==========================================');
    print('UPLOAD PROFILE IMAGE - DIAGNOSTIC INFO');
    print('==========================================');
    print('API URL: $url');
    print('School ID: $cleanSchoolId');
    print('File path: ${imageFile.path}');
    print('File exists: ${await imageFile.exists()}');

    if (await imageFile.exists()) {
      final fileSize = await imageFile.length();
      print('File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
    }

    // Verify file exists
    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist at path: ${imageFile.path}');
    }

    // Create multipart request
    var request = http.MultipartRequest('PUT', url);

    // Add headers
    request.headers.addAll({
      'Accept': 'application/json',
      // Don't set Content-Type - let http package handle it
    });

    // Add file
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final fileBytes = await imageFile.readAsBytes();

    var multipartFile = http.MultipartFile.fromBytes(
      'profileImage', // Must match multer field name
      fileBytes,
      filename: fileName,
    );

    request.files.add(multipartFile);

    print('Multipart file added:');
    print('  - Field name: profileImage');
    print('  - Filename: $fileName');
    print('  - Size: ${fileBytes.length} bytes');
    print('Request headers: ${request.headers}');
    print('Sending request...');

    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('==========================================');
    print('RESPONSE RECEIVED');
    print('==========================================');
    print('Status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');
    print('==========================================');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('updatedStudent')) {
        return Student.fromJson(data['updatedStudent']);
      }
      return Student.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Student not found');
    } else if (response.statusCode == 400) {
      Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Bad request');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: ${response.body}');
    } else {
      throw Exception('Upload failed with status ${response.statusCode}: ${response.body}');
    }
  } catch (error) {
    print('ERROR in uploadProfileImage: $error');
    rethrow;
  }
}
```

---

## Testing Steps

### 1. Test the Backend Endpoint Directly

Use this curl command to test your backend:

```bash
# Replace with actual values
curl -X PUT \
  http://localhost:3000/student/updateStudentProfileImage/YOUR_SCHOOL_ID \
  -H "Accept: application/json" \
  -F "profileImage=@/path/to/test/image.jpg"
```

If this works, the backend is fine and the issue is in Flutter.
If this fails, the backend needs the fixes above.

### 2. Check Backend Logs

When you run your Flutter app, check the Node.js console for the debug logs from the controller. You should see:
```
=== Update Profile Image Request ===
School ID: 123456
File received: YES
...
```

If you see `File received: NO`, then multer isn't receiving the file, which means body-parser is interfering.

### 3. Test from Flutter

Run your app and try uploading an image. Check both Flutter console and backend console.

---

## Most Likely Solution

**The #1 most common issue** is body-parser consuming the request before multer.

**Quick Fix**: In your main server file, move these lines:

```typescript
// MOVE THESE
app.use(express.json());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
```

**TO AFTER** your student route registration:

```typescript
// Register student routes FIRST
app.use("/student", studentRoutes);

// THEN apply body parsers
app.use(express.json());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Then other routes
app.use("/auth", clearingOfficer);
// ... etc
```

---

## Additional Debugging

If the above doesn't work, add this middleware RIGHT BEFORE your student route to see what's happening:

```typescript
// Debug middleware - add this temporarily
app.use('/student/updateStudentProfileImage', (req, res, next) => {
  console.log('=== DEBUG MIDDLEWARE ===');
  console.log('Method:', req.method);
  console.log('Content-Type:', req.headers['content-type']);
  console.log('Body:', req.body);
  console.log('File:', req.file);
  console.log('Files:', req.files);
  console.log('=======================');
  next();
});

app.use("/student", studentRoutes);
```

This will show you exactly what the request looks like when it reaches your route.
