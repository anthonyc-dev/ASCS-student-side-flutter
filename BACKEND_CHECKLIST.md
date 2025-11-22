# Backend Fix Checklist - Image Upload 500 Error

## Your Current Error

```
✅ Flutter: Sending file correctly (111481 bytes)
✅ Request: Reaching backend (https://ascs.space)
❌ Backend: Returning 500 Internal Server Error (HTML page)
```

**Problem**: Body-parser is consuming the request before multer can read the file.

---

## Quick Fix Checklist

### Step 1: Find Your Backend Entry Point File

This is usually one of these files:
- `src/index.ts`
- `src/server.ts`
- `src/app.ts`
- `index.ts`
- `server.ts`

✅ I found it: ___________________

---

### Step 2: Check Current Middleware Order

Look for these lines in your entry point file:

```typescript
app.use(express.json());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use("/student", studentRoutes);
```

**Current order** (write line numbers):
- Line _____: `app.use(express.json())`
- Line _____: `app.use(bodyParser...)`
- Line _____: `app.use("/student", ...)`

---

### Step 3: Fix the Order

**Change from:**
```typescript
app.use(express.json());                    // ❌ Body parser FIRST
app.use(bodyParser.json());
app.use(bodyParser.urlencoded(...));
app.use("/student", studentRoutes);         // ❌ Routes AFTER
```

**To:**
```typescript
app.use("/student", studentRoutes);         // ✅ Routes FIRST
app.use(express.json());                    // ✅ Body parser AFTER
app.use(bodyParser.json());
app.use(bodyParser.urlencoded(...));
```

✅ I fixed the order: [ ]

---

### Step 4: Remove Duplicate Body Parsers

You have BOTH `express.json()` and `bodyParser.json()`. You only need ONE.

**Option A: Use only Express (Recommended)**

DELETE these lines:
```typescript
import bodyParser from "body-parser";  // DELETE
app.use(bodyParser.json());            // DELETE
app.use(bodyParser.urlencoded(...));   // DELETE
```

KEEP only:
```typescript
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
```

**Option B: Use only bodyParser**

DELETE these lines:
```typescript
app.use(express.json());               // DELETE
app.use(express.urlencoded(...));      // DELETE
```

KEEP only:
```typescript
import bodyParser from "body-parser";
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
```

I chose: [ ] Option A (Express)  [ ] Option B (bodyParser)

✅ I removed duplicates: [ ]

---

### Step 5: Final Configuration

Your backend entry point should now look like this:

```typescript
import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
// NO bodyParser import needed

import studentRoutes from "./routes/student.route";
// ... other imports

const app = express();

// 1. CORS
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "Accept"],
}));

// 2. Cookie parser
app.use(cookieParser());

// 3. Student routes FIRST (has file upload)
app.use("/student", studentRoutes);

// 4. Body parsers AFTER
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 5. Other routes
app.use("/auth", clearingOfficer);
app.use("/qr-code", qrCodeRoutes);
// ... rest

export default app;
```

✅ My config matches this: [ ]

---

### Step 6: Verify Student Route

Open your student route file (usually `src/routes/student.route.ts`).

Find this line:
```typescript
router.put(
  "/updateStudentProfileImage/:schoolId",
  upload.single("profileImage"),
  updateStudentProfileImage
);
```

Check:
- ✅ Method is PUT: [ ]
- ✅ Path includes `:schoolId`: [ ]
- ✅ `upload.single("profileImage")` is present: [ ]
- ✅ Field name is `"profileImage"` (matches Flutter): [ ]

---

### Step 7: Restart Backend

Stop your backend server (Ctrl+C) and start it again:

```bash
npm run dev
```

✅ Backend restarted: [ ]

---

### Step 8: Check Backend Console on Startup

When your backend starts, you should see these logs (if you added debug logging):

```
✅ Registering student routes with file upload...
📦 Initializing multer configuration...
✅ Multer configured successfully
✅ Applying body parsers...
```

If you don't see these, add console.log statements:

```typescript
console.log("✅ Registering student routes...");
app.use("/student", studentRoutes);

console.log("✅ Applying body parsers...");
app.use(express.json());
```

✅ I see the logs: [ ]

---

### Step 9: Test Upload from Flutter

1. Run your Flutter app
2. Try to upload an image with schoolId: `21-0854`
3. Watch your backend console

**What should happen in backend console:**

```
📸 IMAGE UPLOAD ROUTE HIT
Method: PUT
School ID: 21-0854
Content-Type: multipart/form-data; boundary=...

✅ AFTER MULTER MIDDLEWARE
File received? true
```

**If you see:**
- `File received? false` → Body parser is still running first
- `Student not found` → Use a valid schoolId from your database
- No logs at all → Route is not registered correctly

✅ I see file received: [ ] Yes  [ ] No

---

### Step 10: Check Flutter Response

**Success (200):**
```json
{
  "success": true,
  "message": "Profile image updated successfully",
  "updatedStudent": { ... }
}
```

**Still 500 Error:**
- Check backend console for the actual error
- Share the error with me

✅ Got 200 success: [ ]

---

## Common Issues

### Issue 1: "File received? false"
**Cause**: Body parser is still running before multer
**Fix**: Make absolutely sure student routes are registered BEFORE body parsers

### Issue 2: "Student not found"
**Cause**: The schoolId doesn't exist in your database
**Fix**: Use a valid schoolId from your database

### Issue 3: Cloudinary error
**Cause**: Cloudinary credentials are missing or wrong
**Fix**: Check your `.env` file has:
```
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
```

### Issue 4: Still getting HTML error page
**Cause**: Backend is crashing for another reason
**Fix**: Check your backend console for the actual error message

---

## After Completing Checklist

If you completed all steps and still get errors, please provide:

1. **Backend console output** when you try to upload (copy/paste)
2. **The middleware order** in your main file (show me the lines)
3. **Does route file have upload.single("profileImage")?** Yes/No
4. **What error shows in backend console?** (copy/paste)

I'll help you debug further!

---

## Success Indicators

✅ Backend starts without errors
✅ You see "Registering student routes" log
✅ Request reaches backend (you see logs)
✅ "File received? true" appears in console
✅ Flutter receives 200 status code
✅ Image URL is returned in response
✅ Image is uploaded to Cloudinary

If all checked, your upload is working! 🎉
