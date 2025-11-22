# Fix 500 Internal Server Error

## Your Error

```
Response status: 500
Response body: <!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>Internal Server Error</pre>
</body>
</html>
```

This HTML error page means your backend is **crashing** when trying to process the file upload.

## Root Cause

The body-parser middleware is consuming the request body before multer can read it, causing `req.file` to be undefined.

---

## DEFINITIVE FIX

### Step 1: Update Your Main Server File

**Location**: Your backend entry point (likely `src/index.ts` or `src/server.ts` or `src/app.ts`)

Replace your middleware section with this EXACT configuration:

```typescript
import express, { Application, Request, Response } from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
// REMOVE bodyParser import if you have it
// import bodyParser from "body-parser"; // DELETE THIS LINE

import path from "path";
import { Server } from "socket.io";
import http from "http";

// All your route imports
import studentRoutes from "./routes/student.route";
// ... other imports

const app: Application = express();

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "../views"));

// ============================================
// CRITICAL: Middleware order MUST be exact!
// ============================================

// 1. CORS first
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "Accept"],
  })
);

// 2. Cookie parser
app.use(cookieParser());

// 3. NO BODY PARSERS HERE!

// 4. Register student routes FIRST (has file upload)
console.log("✅ Registering student routes with file upload...");
app.use("/student", studentRoutes);

// 5. NOW apply body parsers AFTER student routes
console.log("✅ Applying body parsers...");
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// 6. Register all other routes
app.use("/auth", clearingOfficer);
app.use("/qr-code", qrCodeRoutes);
// ... rest of your routes

// Rest of your server setup
const server = http.createServer(app);
// ... socket.io, etc.

export default app;
```

---

### Step 2: Add Debug Logging to Your Student Route

**Location**: Your student route file (likely `src/routes/student.route.ts`)

Add logging middleware:

```typescript
import { Router } from "express";
import { upload } from "../middleware/upload"; // Adjust path
import {
  updateStudentProfileImage,
  getStudentBySchoolId,
  updateStudent,
} from "../controllers/student.controller"; // Adjust path

const router = Router();

// Add debug middleware BEFORE the route
router.put(
  "/updateStudentProfileImage/:schoolId",
  (req, res, next) => {
    console.log("\n╔═══════════════════════════════════════════╗");
    console.log("║  📸 IMAGE UPLOAD ROUTE HIT                ║");
    console.log("╚═══════════════════════════════════════════╝");
    console.log("Method:", req.method);
    console.log("School ID:", req.params.schoolId);
    console.log("Content-Type:", req.headers["content-type"]);
    console.log("Content-Length:", req.headers["content-length"]);
    console.log("Has req.body before multer?", !!req.body);
    console.log("Body:", req.body);
    next();
  },
  upload.single("profileImage"),
  (req, res, next) => {
    console.log("\n╔═══════════════════════════════════════════╗");
    console.log("║  ✅ AFTER MULTER MIDDLEWARE               ║");
    console.log("╚═══════════════════════════════════════════╝");
    console.log("File received?", !!req.file);
    if (req.file) {
      console.log("File details:", {
        fieldname: req.file.fieldname,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
        buffer: !!req.file.buffer,
      });
    } else {
      console.log("❌ NO FILE RECEIVED!");
      console.log("req.body:", req.body);
      console.log("req.files:", req.files);
    }
    console.log("═══════════════════════════════════════════\n");
    next();
  },
  updateStudentProfileImage
);

// Other routes
router.get("/getStudentBySchoolId/:schoolId", getStudentBySchoolId);
router.put("/updateStudent/:studentId", updateStudent);

export default router;
```

---

### Step 3: Update Your Multer Configuration

**Location**: Your upload middleware file (likely `src/middleware/upload.ts`)

```typescript
import multer from "multer";

console.log("📦 Initializing multer configuration...");

// Memory storage
const storage = multer.memoryStorage();

// File filter
const fileFilter = (
  req: Express.Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  console.log("🔍 Multer fileFilter called:");
  console.log("  - Fieldname:", file.fieldname);
  console.log("  - Originalname:", file.originalname);
  console.log("  - Mimetype:", file.mimetype);

  if (file.mimetype.startsWith("image/")) {
    console.log("  ✅ Image accepted");
    cb(null, true);
  } else {
    console.log("  ❌ File rejected - not an image");
    cb(new Error("Only image files are allowed!"));
  }
};

// Multer configuration
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
    files: 1,
  },
});

console.log("✅ Multer configured successfully");
```

---

### Step 4: Enhanced Controller with Error Handling

**Location**: Your student controller

```typescript
import { Request, Response } from "express";

export const updateStudentProfileImage = async (
  req: Request,
  res: Response
) => {
  try {
    console.log("\n╔═══════════════════════════════════════════╗");
    console.log("║  🎯 CONTROLLER: updateStudentProfileImage ║");
    console.log("╚═══════════════════════════════════════════╝");

    const { schoolId } = req.params;
    console.log("School ID:", schoolId);
    console.log("Has file?", !!req.file);

    // Check if file was uploaded
    if (!req.file) {
      console.error("❌ NO FILE in controller!");
      console.log("Headers:", req.headers);
      console.log("Body:", req.body);
      console.log("Files:", req.files);

      res.status(400).json({
        success: false,
        message: "No profile image file provided",
        debug: {
          contentType: req.headers["content-type"],
          hasBody: !!req.body,
          bodyKeys: Object.keys(req.body || {}),
          hasFile: !!req.file,
          hasFiles: !!req.files,
        },
      });
      return;
    }

    console.log("✅ File received:", {
      fieldname: req.file.fieldname,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
    });

    // Fetch the existing student
    const existingStudent = await prisma.student.findUnique({
      where: { schoolId },
    });

    if (!existingStudent) {
      console.error("❌ Student not found");
      res.status(404).json({
        success: false,
        message: "Student not found"
      });
      return;
    }

    console.log("✅ Student found:", existingStudent.firstName);

    // Upload to Cloudinary
    console.log("☁️  Uploading to Cloudinary...");
    let newProfileImageUrl: string;
    try {
      newProfileImageUrl = await uploadImageToCloudinary(
        req.file,
        "student-profile"
      );
      console.log("✅ Cloudinary upload successful");
    } catch (uploadError) {
      console.error("❌ Cloudinary upload failed:", uploadError);
      res.status(500).json({
        success: false,
        message: "Failed to upload profile image",
        error: uploadError instanceof Error ? uploadError.message : String(uploadError),
      });
      return;
    }

    // Delete old image if exists
    if (existingStudent.profileImage) {
      try {
        await deleteImageFromCloudinary(existingStudent.profileImage);
        console.log("✅ Old image deleted");
      } catch (deleteError) {
        console.warn("⚠️  Failed to delete old image:", deleteError);
      }
    }

    // Update database
    console.log("💾 Updating database...");
    const updatedStudent = await prisma.student.update({
      where: { schoolId },
      data: {
        profileImage: newProfileImageUrl,
        updatedAt: new Date(),
      },
    });

    console.log("✅ SUCCESS! Profile image updated");
    console.log("═══════════════════════════════════════════\n");

    res.json({
      success: true,
      message: "Profile image updated successfully",
      updatedStudent,
    });
  } catch (error: any) {
    console.error("\n╔═══════════════════════════════════════════╗");
    console.error("║  ❌ ERROR in updateStudentProfileImage    ║");
    console.error("╚═══════════════════════════════════════════╝");
    console.error("Error:", error);
    console.error("Stack:", error.stack);
    console.error("═══════════════════════════════════════════\n");

    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message || String(error),
    });
  }
};
```

---

## Testing

### Step 1: Restart Your Backend

```bash
# Stop your backend (Ctrl+C)
# Then start it again
npm run dev
# or
node dist/index.js
```

You should see:
```
✅ Registering student routes with file upload...
📦 Initializing multer configuration...
✅ Multer configured successfully
✅ Applying body parsers...
```

### Step 2: Test from Flutter

Run your app and try uploading. You should now see in your backend console:

```
╔═══════════════════════════════════════════╗
║  📸 IMAGE UPLOAD ROUTE HIT                ║
╚═══════════════════════════════════════════╝
Method: PUT
School ID: 21-0854
Content-Type: multipart/form-data; boundary=...

╔═══════════════════════════════════════════╗
║  ✅ AFTER MULTER MIDDLEWARE               ║
╚═══════════════════════════════════════════╝
File received? true
File details: {
  fieldname: 'profileImage',
  originalname: 'scaled_1000044610.jpg',
  mimetype: 'image/jpeg',
  size: 111481,
  buffer: true
}
```

---

## What to Look For

### If you see "File received? false" in backend logs:

This means body-parser is still consuming the request. Make sure:
1. Student routes are registered BEFORE body parsers
2. You removed the `bodyParser` import
3. You restarted the backend server

### If you see "Student not found":

The schoolId `21-0854` doesn't exist in your database. Use a valid schoolId.

### If you see Cloudinary errors:

Your Cloudinary configuration might be missing or incorrect. Check your `.env` file.

---

## Still Not Working?

If you still get errors after this, please share:

1. **Your backend console output** (copy everything when you try to upload)
2. **The exact line in your main server file** where you register routes
3. **Screenshot** of your backend logs if possible

I'll provide a more specific fix!
