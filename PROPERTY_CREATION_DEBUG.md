# Property Creation & Image Upload - Debug Guide

## 🔍 Issues Fixed

### Issue 1: Wrong API URL for User Fetch ✅ FIXED
**Problem**: `PropertyDataManager._getCurrentUserId()` was using `AppString.apiBaseUrl` (localhost) instead of `ApiConfig.baseUrl`

**Fix**: Changed line 62 in `lib/services/post_bien_immo_service.dart`:
```dart
// Before:
Uri.parse('${AppString.apiBaseUrl}/me')

// After:
Uri.parse('${ApiConfig.baseUrl}/me')
```

### Issue 2: No Debug Logging ✅ FIXED
**Problem**: Couldn't see where the submission was failing

**Fix**: Added comprehensive logging throughout the submission flow:
- Property validation
- API data preparation
- User ID fetch
- BienImmo creation
- Image upload
- Detailed error messages with stack traces

---

## 🧪 How to Test

### Step 1: Start Backend
```bash
cd C:\Users\almam\immo\immo-api
npm start
```

Should show:
```
✅ Created uploads directory: ...
Server is running at http://[::1]:3000
```

### Step 2: Run Flutter App
```bash
cd C:\Users\almam\immo\maxim-flutter
flutter run
```

### Step 3: Create a Property with Images

1. Go through the property creation flow
2. Fill in all required fields
3. Add some images
4. Submit the property

### Step 4: Watch Console Output

**Expected successful flow:**

```
================================================================================
🏠 STARTING PROPERTY SUBMISSION
================================================================================
✅ Validation passed
📦 Getting ApiService...
✅ ApiService found
📋 Preparing API data...
🔍 Getting current user ID from: http://192.168.1.4:3000/me
📡 Response status: 200
Current user ID: 674xxxxxxxxxxxxx
✅ API data prepared
📄 Data structure:
   - typeBien: maison
   - localisation: Paris
   - prix HAI: 450000
   - utilisateurId: 674xxxxxxxxxxxxx
📸 Found 3 images to upload
   Image 1: /path/to/image1.jpg
   Image 2: /path/to/image2.jpg
   Image 3: /path/to/image3.jpg

🚀 Calling submitPropertyWithImages...
   - API Base URL: http://192.168.1.4:3000
   - Creating BienImmo first, then uploading images

🏠 Starting complete property submission...
🚀 Creating BienImmo without images...
🚀 Creating BienImmo with data: {typeBien: maison, ...}
📡 API Response Status: 200
📡 API Response Body: {"id":"675xxxxxxxxxxxxx",...}
✅ BienImmo created successfully with ID: 675xxxxxxxxxxxxx
📸 Uploading 3 images to BienImmo 675xxxxxxxxxxxxx...
📸 Uploading image 1/3 to BienImmo 675xxxxxxxxxxxxx
📱 Mobile upload: Using multipart...
✅ Image uploaded: uploads/bien-immos/1733312345678-123.jpg
📸 Uploading image 2/3 to BienImmo 675xxxxxxxxxxxxx
📱 Mobile upload: Using multipart...
✅ Image uploaded: uploads/bien-immos/1733312345679-456.jpg
📸 Uploading image 3/3 to BienImmo 675xxxxxxxxxxxxx
📱 Mobile upload: Using multipart...
✅ Image uploaded: uploads/bien-immos/1733312345680-789.jpg
📸 Upload complete: 3/3 images uploaded to BienImmo 675xxxxxxxxxxxxx
✅ Images uploaded successfully: [uploads/bien-immos/...]
🎉 Property submission complete! ID: 675xxxxxxxxxxxxx, Images: 3

📡 Submission response received:
   - Result: Success
   - ID: 675xxxxxxxxxxxxx
   - Image count: 3
   - Uploaded images: [uploads/bien-immos/1733312345678-123.jpg, ...]
✅ BienImmo created successfully with ID: 675xxxxxxxxxxxxx
🎉 Property submitted successfully with ID: 675xxxxxxxxxxxxx
🔚 Submission process ended (isSubmitting = false)
```

**Backend should show:**
```
📸 Processing 3 file(s) for BienImmo 675xxxxxxxxxxxxx
✅ Uploaded: 1733312345678-123.jpg
✅ Uploaded: 1733312345679-456.jpg
✅ Uploaded: 1733312345680-789.jpg
💾 Updated BienImmo 675xxxxxxxxxxxxx with 3 images
```

---

## 🐛 Common Errors & Solutions

### Error 1: "Failed to fetch user: 401"

**Console shows:**
```
🔍 Getting current user ID from: http://192.168.1.4:3000/me
📡 Response status: 401
Error getting current user ID: Exception: Failed to fetch user: 401
```

**Cause**: Authentication token is invalid or expired

**Fix**:
1. Log out and log back in
2. Check backend `/me` endpoint exists
3. Verify token is being sent correctly

### Error 2: "Failed to create BienImmo: 422"

**Console shows:**
```
🚀 Creating BienImmo with data: {...}
📡 API Response Status: 422
❌ Failed to create BienImmo: {"error": {"statusCode": 422, "name": "ValidationError", ...}}
```

**Cause**: Missing required fields or invalid data format

**Fix**:
1. Check the "📄 Data structure" output for null values
2. Verify all required fields are filled
3. Check backend model validation rules

### Error 3: "No authentication token found"

**Console shows:**
```
Error getting current user ID: Exception: No authentication token found
Using fallback user ID: user-1733312345678
```

**Cause**: User not logged in

**Fix**: Make sure user is logged in before creating property

### Error 4: "Mobile image upload failed: 404"

**Console shows:**
```
📱 Mobile upload: Using multipart...
❌ Mobile image upload failed: {"error":{"statusCode":404,"message":"..."}}
```

**Cause**: Upload endpoint doesn't exist on backend

**Fix**: Make sure you:
1. Installed multer: `npm install multer @types/multer`
2. Built backend: `npm run build`
3. Restarted backend: `npm start`

### Error 5: Connection refused / Network error

**Console shows:**
```
💥 Exception creating BienImmo: SocketException: Connection refused
```

**Cause**: Can't reach backend

**Fix**:
1. Backend is running: `npm start`
2. Phone and PC on same WiFi
3. `ApiConfig.baseUrl` has correct IP
4. Backend listening on `0.0.0.0:3000` (not `localhost:3000`)

---

## ✅ Verify Everything Works

### 1. Check Backend Received Property

In MongoDB:
```javascript
db.BienImmo.find().sort({datePublication: -1}).limit(1).pretty()

// Should show:
// {
//   _id: ObjectId("675..."),
//   typeBien: "maison",
//   listeImages: [
//     "uploads/bien-immos/1733312345678-123.jpg",
//     "uploads/bien-immos/1733312345679-456.jpg",
//     "uploads/bien-immos/1733312345680-789.jpg"
//   ],
//   utilisateurId: "674...",
//   ...
// }
```

### 2. Check Files Saved

```bash
ls C:\Users\almam\immo\immo-api\uploads\bien-immos\

# Should show:
# 1733312345678-123.jpg
# 1733312345679-456.jpg
# 1733312345680-789.jpg
```

### 3. Check Images Accessible

Open browser to:
```
http://192.168.1.4:3000/uploads/bien-immos/1733312345678-123.jpg
```

Should display the uploaded image.

### 4. Check Activity Tab Shows Property

Go to Activity tab in app - should show your new property with real images!

---

## 📋 Debug Checklist

Use this checklist to track where the issue is:

- [ ] ✅ Backend running on correct IP
- [ ] ✅ Flutter app using `ApiConfig.baseUrl` everywhere
- [ ] ✅ User logged in (has auth token)
- [ ] ✅ `/me` endpoint returns user ID
- [ ] ✅ Property data prepared correctly
- [ ] ✅ BienImmo created (status 200)
- [ ] ✅ Images uploaded (3/3 success)
- [ ] ✅ Files saved to `uploads/bien-immos/`
- [ ] ✅ MongoDB has `listeImages` populated
- [ ] ✅ Images accessible in browser
- [ ] ✅ Activity tab shows property with images

**If all checked**: Everything is working! 🎉

**If stuck at any step**: Read the error message in console and check the corresponding section above.

---

## 🚀 Next Steps

Once property creation works:

1. Test editing properties
2. Test deleting properties
3. Test image deletion
4. Verify images display in all views (Home, Search, Details)

---

## 📞 Need Help?

If you see an error not listed here, copy:

1. **Console output** from "🏠 STARTING PROPERTY SUBMISSION" to the end
2. **Backend logs** showing the request
3. **Error message** from the red snackbar

This will help identify the exact problem!
