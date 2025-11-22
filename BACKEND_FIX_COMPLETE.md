# Complete Backend Fix for Image Upload

## The Problem

Body parsers (express.json, bodyParser, etc.) consume the request body, preventing multer from reading the file. This is a very common issue.

## Complete Working Solution

Replace your entire backend entry point with this configuration:

```typescript
import express, { Application, Request, Response } from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
// DO NOT IMPORT body-parser package
// import bodyParser from "body-parser"; // REMOVE THIS
import path from "path";
import { Server } from "socket.io";
import http from "http";

// Import all routes
import clearingOfficer from "./routes/clearingOfficer.route";
import qrCodeRoutes from "./routes/qrCode.route";
import requirementReq from "./routes/requirement.route";
import studentRoutes from "./routes/student.route";
import enrollmentStudentManagementRoute from "./routes/enrollment/enrollment-student-management.route";
import enrollmentSemesterRoute from "./routes/enrollment/enrollment-semester.route";
import enrollmentCourseRoute from "./routes/enrollment/enrollment-addCourse.route";
import enrollmentSectionRoute from "./routes/enrollment/enrollment-section.route";
import enrollmentRoutes from "./routes/enrollment/enrollment.routes";
import enrollmentAuthRoute from "./routes/enrollment/enrollment-auth.route";
import updatePass from "./routes/intigration.route";
import studentRequirement from "./routes/studentRequirement.route";
import institutionalRoute from "./routes/institutional.route";
import eventRoutes from "./routes/event.route";
import setupClearance from "./routes/setupClearance.route";
import studentReqInstitutional from "./routes/studentReqInstitutional.route";
import createNotif from "./routes/notification.route";
import sendSMSRoutes from "./routes/send-sms.route";

const app: Application = express();

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "../views"));

// ============================================
// CRITICAL: Order of middleware matters!
// ============================================

// 1. CORS (must be first)
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "Accept",
      "Origin",
      "X-Requested-With",
    ],
    credentials: false,
  })
);

// 2. Cookie parser
app.use(cookieParser());

// 3. IMPORTANT: Register file upload routes BEFORE body parsers
console.log("🚀 Registering student routes (with file upload)...");
app.use("/student", studentRoutes);

// 4. NOW apply body parsers (they won't affect routes registered above)
console.log("📝 Applying body parsers...");
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// 5. Register all other routes
console.log("📋 Registering other routes...");

// HTTP server wrapper
const server = http.createServer(app);

// Socket.IO
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);
  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

export { io };

// Health check
app.get("/health", (_req: Request, res: Response): void => {
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
  });
});

app.get("/", (_req: Request, res: Response): void => {
  res.render("index");
});

// ASCS routes
app.use("/auth", clearingOfficer);
app.use("/qr-code", qrCodeRoutes);
app.use("/req", requirementReq);
app.use("/clearance", setupClearance);
app.use("/updateUser", updatePass);
app.use("/studentReq", studentRequirement);

// Enrollment routes
app.use("/enrollment-auth", enrollmentAuthRoute);
app.use("/student-management", enrollmentStudentManagementRoute);
app.use("/semester-management", enrollmentSemesterRoute);
app.use("/courses", enrollmentCourseRoute);
app.use("/sections", enrollmentSectionRoute);
app.use("/enroll", enrollmentRoutes);

// Other routes
app.use("/event", eventRoutes);
app.use("/institutionalReq", studentReqInstitutional);
app.use("/institutional", institutionalRoute);
app.use("/notif", createNotif);
app.use("/sms", sendSMSRoutes);

// Error handling middleware
app.use((err: any, req: Request, res: Response, next: any) => {
  console.error("❌ Error:", err);
  res.status(err.status || 500).json({
    message: err.message || "Internal server error",
    error: process.env.NODE_ENV === "development" ? err : {},
  });
});

export default app;
```

---

## Student Route File Configuration

Make sure your `student.route.ts` looks like this:

```typescript
import { Router } from "express";
import { upload } from "../middleware/upload"; // Adjust path as needed
import {
  updateStudentProfileImage,
  getStudentBySchoolId,
  updateStudent,
  // ... other controllers
} from "../controllers/student.controller";

const router = Router();

// ⚠️ CRITICAL: Image upload route
router.put(
  "/updateStudentProfileImage/:schoolId",
  (req, res, next) => {
    console.log("🔍 Image upload route hit");
    console.log("  Method:", req.method);
    console.log("  SchoolId:", req.params.schoolId);
    console.log("  Content-Type:", req.headers["content-type"]);
    next();
  },
  upload.single("profileImage"),
  (req, res, next) => {
    console.log("✅ After multer middleware");
    console.log("  File received:", !!req.file);
    if (req.file) {
      console.log("  File details:", {
        fieldname: req.file.fieldname,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
      });
    }
    next();
  },
  updateStudentProfileImage
);

// Other routes
router.get("/getStudentBySchoolId/:schoolId", getStudentBySchoolId);
router.put("/updateStudent/:studentId", updateStudent);
// ... other routes

export default router;
```

---

## Upload Middleware Configuration

Your `upload.ts` (multer config) should look like this:

```typescript
import multer from "multer";

console.log("📦 Configuring multer...");

// Memory storage
const storage = multer.memoryStorage();

// File filter
const fileFilter = (
  req: Express.Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  console.log("🔍 Multer fileFilter:", {
    fieldname: file.fieldname,
    originalname: file.originalname,
    mimetype: file.mimetype,
  });

  if (file.mimetype.startsWith("image/")) {
    console.log("✅ Image accepted");
    cb(null, true);
  } else {
    console.log("❌ File rejected - not an image");
    cb(new Error("Only image files are allowed!"));
  }
};

// Export multer instance
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});

console.log("✅ Multer configured successfully");
```

---

## Enhanced Controller with Full Logging

```typescript
import { Request, Response } from "express";
import { prisma } from "../lib/prisma"; // Adjust import
import {
  uploadImageToCloudinary,
  deleteImageFromCloudinary,
} from "../services/cloudinary"; // Adjust import

export const updateStudentProfileImage = async (
  req: Request,
  res: Response
) => {
  try {
    console.log("\n═══════════════════════════════════════════");
    console.log("📸 UPDATE STUDENT PROFILE IMAGE");
    console.log("═══════════════════════════════════════════");

    const { schoolId } = req.params;
    console.log("School ID:", schoolId);
    console.log("Headers:", req.headers);
    console.log("File received:", !!req.file);

    // Check if file exists
    if (!req.file) {
      console.error("❌ NO FILE RECEIVED");
      console.log("Request body:", req.body);
      console.log("Request files:", req.files);

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

    console.log("✅ File details:", {
      fieldname: req.file.fieldname,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      buffer: !!req.file.buffer,
    });

    // Find student
    console.log("🔍 Finding student...");
    const existingStudent = await prisma.student.findUnique({
      where: { schoolId },
    });

    if (!existingStudent) {
      console.error("❌ Student not found");
      res.status(404).json({
        success: false,
        message: "Student not found",
      });
      return;
    }

    console.log("✅ Student found:", existingStudent.firstName, existingStudent.lastName);

    // Upload to Cloudinary
    console.log("☁️  Uploading to Cloudinary...");
    let newProfileImageUrl: string;
    try {
      newProfileImageUrl = await uploadImageToCloudinary(
        req.file,
        "student-profile"
      );
      console.log("✅ Upload successful:", newProfileImageUrl);
    } catch (uploadError) {
      console.error("❌ Cloudinary upload failed:", uploadError);
      res.status(500).json({
        success: false,
        message: "Failed to upload profile image",
        error:
          uploadError instanceof Error
            ? uploadError.message
            : String(uploadError),
      });
      return;
    }

    // Delete old image
    if (existingStudent.profileImage) {
      console.log("🗑️  Deleting old image...");
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

    console.log("✅ Profile image updated successfully!");
    console.log("═══════════════════════════════════════════\n");

    res.json({
      success: true,
      message: "Profile image updated successfully",
      updatedStudent,
    });
  } catch (error: any) {
    console.error("❌ ERROR in updateStudentProfileImage:", error);
    console.error("Stack:", error.stack);
    console.log("═══════════════════════════════════════════\n");

    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message || String(error),
    });
  }
};
```

---

## Testing Checklist

After applying these changes:

1. ✅ Restart your backend server
2. ✅ Check console logs - you should see:
   ```
   🚀 Registering student routes (with file upload)...
   📦 Configuring multer...
   ✅ Multer configured successfully
   📝 Applying body parsers...
   ```

3. ✅ Try uploading from Flutter
4. ✅ Check the detailed logs in your backend console

---

## If Still Not Working

If you still get errors after this, please provide:

1. **The EXACT error message** from Flutter console
2. **The EXACT logs** from your Node.js console
3. **The HTTP status code** you're receiving
4. **Screenshot** of the error if possible

This will help me identify the exact issue!
