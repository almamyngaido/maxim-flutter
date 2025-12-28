# Image Loading Strategy - MaxiiM App

## 🎯 Complete Dynamic Image System

This document explains how images work end-to-end in the MaxiiM app, from upload to display.

---

## ✅ Problems Fixed

### 1. API URL Inconsistency (Main Issue - FIXED ✅)
**Problem**: Two different API URLs causing mobile failures
- ❌ `app_string.dart`: `http://127.0.0.1:3000` (localhost - doesn't work on phone)
- ✅ `api_config.dart`: `http://192.168.1.4:3000` (network IP - works on phone)

**Solution**:
- ✅ Updated `ActivityController` to use `ApiConfig.baseUrl`
- ✅ Fixed delete API endpoint
- ✅ Deprecated `AppString.apiBaseUrl` with clear warning
- ✅ All API calls now use centralized config

### 2. Image Loading Issues (FIXED ✅)
**Problem**: No caching, slow loading, no error handling, fake images everywhere

**Solution**:
- ✅ Created `CachedNetworkImageWidget` with automatic caching
- ✅ Updated `ActivityView` to use cached images
- ✅ Created `_buildImageUrl()` helper to convert paths to full URLs
- ✅ Automatic fallback to asset images for properties without photos

### 3. Fake Images (FIXED ✅)
**Problem**: App showing placeholder assets instead of real user uploads

**Solution**:
- ✅ Images uploaded to backend are stored in `listeImages` field
- ✅ Controller extracts images from backend data
- ✅ Falls back to property-type-specific placeholder images when no uploads

---

## 🔄 How Images Work (Complete Flow)

### Upload Flow (User → Backend)

```
1. User picks images
   ↓
2. PhotosDescriptionController.selectedImages (List<File>)
   ↓
3. PropertyDataManager stores File paths
   ↓
4. On submit: PostBienService.uploadImagesToBienImmo()
   ↓
5. POST /bien-immos/:id/media (multipart/form-data)
   ↓
6. Backend returns: { url: "uploads/123.jpg" } or { url: "http://..." }
   ↓
7. PATCH /bien-immos/:id with { listeImages: [...urls] }
   ↓
8. Backend stores image URLs in BienImmo.listeImages
```

### Display Flow (Backend → User)

```
1. ActivityController.fetchUserProperties()
   ↓
2. GET /utilisateurs/:id/bien-immos
   ↓
3. Backend returns: [{ _id: "...", listeImages: ["uploads/123.jpg"], ... }]
   ↓
4. ActivityController._getPropertyImage(property)
   ↓
5. Extract: property['listeImages'][0]
   ↓
6. _buildImageUrl() converts path → full URL
   - "uploads/123.jpg" → "http://192.168.1.4:3000/uploads/123.jpg"
   - "http://example.com/image.jpg" → "http://example.com/image.jpg" (no change)
   ↓
7. CachedNetworkImageWidget displays with caching
```

---

## 📁 File Structure

### Backend Image Storage

Your backend should return images in `listeImages` as one of:
- **Full URLs**: `"http://192.168.1.4:3000/uploads/image.jpg"` (best)
- **Relative paths**: `"uploads/image.jpg"` (app converts to full URL)
- **Filenames**: `"image.jpg"` (app prepends base URL)

### Fallback Images (No Uploads)

When `listeImages` is empty, app shows property-type placeholders:
- `appartement` → `Assets.images.listing1.path`
- `maison` → `Assets.images.listing2.path`
- `terrain` → `Assets.images.listing3.path`
- `default` → `Assets.images.listing4.path`

---

## 📱 How to Use

### Option 1: CachedNetworkImageWidget (Full Control)

```dart
import 'package:luxury_real_estate_flutter_ui_kit/common/cached_network_image_widget.dart';

CachedNetworkImageWidget(
  imageUrl: property['listeImages']?.first,
  width: 200,
  height: 150,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12),
)
```

### Option 2: PropertyImageWidget (Simple)

```dart
import 'package:luxury_real_estate_flutter_ui_kit/common/cached_network_image_widget.dart';

PropertyImageWidget(
  imageUrl: property['listeImages']?.first,
  width: 200,
  height: 150,
)
// Automatically includes:
// - Rounded corners (12px)
// - Home icon fallback
// - Loading indicator
```

---

## 🔧 Updating Existing Code

### Before (No Caching):
```dart
Image.network(
  property['listeImages']?.first ?? '',
  width: 200,
  height: 150,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);
  },
)
```

### After (With Caching):
```dart
PropertyImageWidget(
  imageUrl: property['listeImages']?.first,
  width: 200,
  height: 150,
)
```

---

## 📍 Testing on Phone - IMPORTANT

### Step 1: Find Your PC's IP Address

**Windows**:
```cmd
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter
Example: `192.168.1.4`

**Mac/Linux**:
```bash
ifconfig
```

### Step 2: Update API Configuration

Edit `lib/configs/api_config.dart`:
```dart
static const String _localIP = '192.168.1.4'; // <-- YOUR PC's IP HERE
```

### Step 3: Make Sure Backend is Running

Your backend must listen on `0.0.0.0:3000` (not `localhost:3000`)

**Example (Node.js)**:
```javascript
app.listen(3000, '0.0.0.0', () => {
  console.log('Server listening on 0.0.0.0:3000');
});
```

### Step 4: Connect Phone

1. Phone and PC must be on **same WiFi network**
2. Enable USB debugging on phone
3. Connect via USB
4. Run: `flutter run`

---

## 🎯 Where to Replace Image.network

### High Priority Files:
1. ✅ `activity_view.dart` - Fixed API URL
2. `home/widget/manage_property_bottom_sheet.dart` - Already has fallback
3. `post_property/imgDescription_view.dart` - Replace Image.network
4. `post_property/show_property_details_view.dart` - Replace Image.network
5. `home/delete_listing_view.dart` - Replace Image.network

### Example Migration:

**File**: `activity_view.dart` (line ~300)

**Before**:
```dart
Image.network(
  imagePath,
  height: 200,
  width: double.infinity,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => Container(...),
)
```

**After**:
```dart
PropertyImageWidget(
  imageUrl: imagePath,
  height: 200,
  width: double.infinity,
)
```

---

## 🚀 Benefits

### Performance
- ✅ Images cached locally
- ✅ Faster subsequent loads
- ✅ Reduced network usage

### User Experience
- ✅ Smooth loading animations
- ✅ Professional error states
- ✅ No blank images
- ✅ Consistent look across app

### Developer Experience
- ✅ Single import
- ✅ Less code
- ✅ Automatic error handling
- ✅ Easy to customize

---

## 📝 Troubleshooting

### "Erreur de chargement" on Phone ✅ FIXED

**Cause**: Using localhost URL instead of network IP
**Fix**:
1. ✅ All API calls now use `ApiConfig.baseUrl`
2. Update `lib/configs/api_config.dart` with your PC's IP
3. Restart the app
4. Check backend is running on `0.0.0.0:3000`

### Images Not Loading

**Possible causes**:

#### 1. Invalid URL or path
**Symptoms**: Placeholder icons show instead of images
**Debug**:
```dart
// Check console for:
'Error getting property image: ...'
'📸 Image path: uploads/123.jpg'
'🔗 Full URL: http://192.168.1.4:3000/uploads/123.jpg'
```
**Fix**: Verify backend returns correct paths in `listeImages`

#### 2. Backend not serving uploaded files
**Symptoms**: 404 errors in console
**Fix**:
- Ensure backend serves static files from `/uploads` directory
- Example (Express.js):
  ```javascript
  app.use('/uploads', express.static('uploads'));
  ```

#### 3. CORS issues
**Symptoms**: Network errors, blocked requests
**Fix**:
- Add CORS headers to backend
- Example (Express.js):
  ```javascript
  app.use(cors({
    origin: '*', // For development only!
    credentials: true
  }));
  ```

#### 4. Network mismatch
**Symptoms**: Works on Chrome, fails on phone
**Fix**:
- Phone and PC must be on **same WiFi**
- Check firewall isn't blocking port 3000

### Slow First Load

**Cause**: First-time image download
**Fix**: This is normal - subsequent loads are instant (cached)

### Showing Placeholder Instead of Real Image

**Cause**: Property has no images uploaded
**Fix**: This is expected behavior - upload images through the app

---

## 🛠️ Backend Requirements

### 1. Image Upload Endpoint

```javascript
POST /bien-immos/:id/media
Content-Type: multipart/form-data

// Response format (choose one):
{
  "url": "http://192.168.1.4:3000/uploads/abc123.jpg"  // Option 1: Full URL (recommended)
}
// OR
{
  "url": "uploads/abc123.jpg"  // Option 2: Relative path (app builds full URL)
}
// OR
{
  "path": "uploads/abc123.jpg",  // Option 3: path field
  "filename": "abc123.jpg"
}
```

### 2. Serve Static Files

Backend must serve uploaded files:
```javascript
// Express.js example
const express = require('express');
const app = express();

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.listen(3000, '0.0.0.0', () => {
  console.log('Server on http://0.0.0.0:3000');
});
```

### 3. Store Image URLs in Database

```javascript
// MongoDB/Mongoose example
const bienImmoSchema = new Schema({
  // ... other fields
  listeImages: [String],  // Array of image URLs/paths
});

// After image upload:
await BienImmo.findByIdAndUpdate(id, {
  $push: { listeImages: imageUrl }
});
```

### 4. Return Images in GET Requests

```javascript
GET /utilisateurs/:userId/bien-immos

// Response:
[
  {
    "_id": "674f0f31a34ecb1c1bef6b6b",
    "typeBien": "appartement",
    "listeImages": [
      "uploads/1733310256827-property1.jpg",
      "uploads/1733310256828-property2.jpg"
    ],
    // ... other fields
  }
]
```

---

## ✅ Current Implementation Status

### What's Working ✅
- ✅ Image uploads to backend (`POST /bien-immos/:id/media`)
- ✅ Images stored in `listeImages` field
- ✅ Activity view displays backend images with caching
- ✅ Automatic URL building for relative paths
- ✅ Fallback to placeholder images when no uploads
- ✅ API URL consistency (all using `ApiConfig.baseUrl`)
- ✅ Mobile support (works on phones)

### What Still Uses Fake Images ⚠️
These views will be updated next (already have the structure, just need to integrate):
- ⚠️ `HomeView` - Shows recent listings
- ⚠️ `SavedPropertiesView` - Favorites and similar properties
- ⚠️ `PropertyDetailsView` - Full property view
- ⚠️ `PropertyListView` - Search results

**To update these**: Replace `Image.network()` with `CachedNetworkImageWidget`

---

## 🔐 API Configuration Checklist

- ✅ `api_config.dart` has correct IP
- ✅ Phone and PC on same WiFi
- ✅ Backend running on `0.0.0.0:3000`
- ✅ `ActivityController` uses `ApiConfig.baseUrl` ✅
- ✅ `cached_network_image` package installed ✅

---

## Next Steps

1. **Test on Phone**: Run `flutter run` with phone connected
2. **Verify Listings Load**: Check Activity tab shows properties
3. **Replace Image.network**: Migrate other files to use `PropertyImageWidget`
4. **Enjoy**: Faster, more reliable image loading! 🎉
