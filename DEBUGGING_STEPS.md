# Debugging Image Upload Issue

## Step 1: Tell me what error you're seeing

Please provide:

1. **What error message do you see in Flutter?** (Copy the full error from your Flutter console)

2. **What do you see in your Node.js backend console?** (Any errors or logs)

3. **What HTTP status code are you getting?** (200, 400, 404, 500, etc.)

---

## Step 2: Add Backend Debugging Code

### Option A: Add this debugging middleware to your backend

Add this **BEFORE** your student route in your main server file:

```typescript
// DEBUG MIDDLEWARE - Add this temporarily
app.use('/student/updateStudentProfileImage/:schoolId', (req, res, next) => {
  console.log('\n============================================');
  console.log('🔍 DEBUG MIDDLEWARE - Image Upload Request');
  console.log('============================================');
  console.log('Method:', req.method);
  console.log('URL:', req.url);
  console.log('Params:', req.params);
  console.log('Content-Type:', req.headers['content-type']);
  console.log('Has req.body?', !!req.body);
  console.log('Body keys:', Object.keys(req.body || {}));
  console.log('Has req.file?', !!req.file);
  console.log('Has req.files?', !!req.files);
  console.log('============================================\n');
  next();
});

app.use("/student", studentRoutes);
```

### Option B: Add logging directly to your multer middleware

In your upload configuration file, add logging:

```typescript
import multer from "multer";

// Configure multer to store files in memory as buffers
const storage = multer.memoryStorage();

// File filter to accept only images
const fileFilter = (
  req: Express.Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  console.log('🔍 Multer fileFilter called');
  console.log('  File:', file);
  console.log('  Mimetype:', file.mimetype);

  if (file.mimetype.startsWith("image/")) {
    console.log('  ✅ File accepted');
    cb(null, true);
  } else {
    console.log('  ❌ File rejected - not an image');
    cb(new Error("Only image files are allowed!"));
  }
};

// Configure multer
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  },
});

// Add error handling
console.log('✅ Multer configured successfully');
```

---

## Step 3: Alternative Backend Fixes

### Fix #1: Completely Remove body-parser (Use Express built-in only)

In your main server file, **remove** these lines:
```typescript
// DELETE THESE:
import bodyParser from "body-parser";
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
```

**Keep only**:
```typescript
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
```

Then reorder:
```typescript
// CORS first
app.use(cors({ /* your config */ }));

// Cookie parser
app.use(cookieParser());

// Student routes BEFORE body parsers
app.use("/student", studentRoutes);

// Body parsers AFTER
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Other routes
app.use("/auth", clearingOfficer);
// ... rest
```

---

### Fix #2: Skip body parsing for upload routes

```typescript
// Custom middleware to skip body parsing for file uploads
app.use((req, res, next) => {
  // Skip body parsing for image upload endpoint
  if (req.path.includes('/updateStudentProfileImage')) {
    console.log('⏭️  Skipping body parser for upload route');
    return next();
  }

  // Apply body parsing for other routes
  express.json()(req, res, (err) => {
    if (err) return next(err);
    express.urlencoded({ extended: true })(req, res, next);
  });
});

// Then add your routes
app.use("/student", studentRoutes);
app.use("/auth", clearingOfficer);
// ... rest
```

---

### Fix #3: Use POST instead of PUT

Sometimes PUT with multipart data can have issues. Try changing to POST:

**Backend Route:**
```typescript
// Change from PUT to POST
router.post(
  "/updateStudentProfileImage/:schoolId",
  upload.single("profileImage"),
  updateStudentProfileImage
);
```

**Flutter Service:**
```dart
// Change from PUT to POST
var request = http.MultipartRequest('POST', url);
```

---

### Fix #4: Create a separate Express app for file uploads

```typescript
import express from 'express';

const app = express();

// CORS
app.use(cors({ /* config */ }));

// Cookie parser
app.use(cookieParser());

// File upload routes WITHOUT body parser
app.use("/student", studentRoutes);

// Body parsers for all OTHER routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// All other routes
app.use("/auth", clearingOfficer);
// ... rest
```

---

## Step 4: Test with CURL

Test your backend directly without Flutter to isolate the issue:

```bash
# Windows PowerShell
curl.exe -X PUT http://localhost:3000/student/updateStudentProfileImage/YOUR_SCHOOL_ID -F "profileImage=@C:\path\to\image.jpg"

# Or using Postman:
# 1. Set method to PUT
# 2. URL: http://localhost:3000/student/updateStudentProfileImage/YOUR_SCHOOL_ID
# 3. Go to Body tab
# 4. Select "form-data"
# 5. Add key "profileImage" and change type to "File"
# 6. Select an image file
# 7. Send request
```

If curl/Postman works but Flutter doesn't, the issue is in Flutter.
If curl/Postman fails too, the issue is in the backend.

---

## Step 5: Check your route registration

Make sure your student route file exports the router correctly:

```typescript
// In your student.route.ts file
import { Router } from "express";
import { upload } from "../path/to/upload"; // Adjust path
import {
  updateStudentProfileImage,
  // other controllers
} from "../controllers/student.controller";

const router = Router();

// Make sure this route is defined
router.put(
  "/updateStudentProfileImage/:schoolId",
  upload.single("profileImage"),
  updateStudentProfileImage
);

// Other routes...

export default router; // Make sure you export default
```

---

## Common Issues Checklist

- [ ] Is your backend server actually running on port 3000?
- [ ] Is the route actually registered? (Check with `console.log` in the controller)
- [ ] Does the schoolId in the URL match an existing student?
- [ ] Is the file actually being sent from Flutter? (Check Flutter logs)
- [ ] Is multer being imported correctly in the route file?
- [ ] Is there any proxy or middleware that might be intercepting the request?
- [ ] Are you testing with an actual device or emulator? (Some emulators have issues with localhost)

---

## Next Steps

1. Run the app and try to upload an image
2. Copy ALL the logs from both Flutter console and Node.js console
3. Share them with me so I can see exactly what's happening
4. Let me know which of the fixes above you've tried
