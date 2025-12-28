# Debug Images Not Showing - Step-by-Step Guide

## 🔍 Problem: Images Show Fake/Placeholders After Upload

Let's debug the complete flow to find where it's breaking.

---

## Step 1: Check Backend Receives Upload

### Test Upload Manually

```bash
# Replace with your actual BienImmo ID
BIEN_IMMO_ID="your-id-here"

curl -X POST "http://192.168.1.4:3000/bien-immos/$BIEN_IMMO_ID/media" \
  -F "file=@/path/to/test-image.jpg" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response:**
```json
{
  "success": true,
  "url": "uploads/bien-immos/1733312345678-xyz.jpg",
  "filename": "1733312345678-xyz.jpg"
}
```

**If you get 404**: The endpoint doesn't exist → See LOOPBACK_IMAGE_SETUP.md

**If you get 500**: Check backend logs for errors

**If you get 200 but no file**: Check uploads directory permissions

---

## Step 2: Check File Actually Saved

### On Backend Server

```bash
# Check if uploads directory exists
ls -la uploads/bien-immos/

# You should see files like:
# 1733312345678-abc.jpg
# 1733312346789-xyz.jpg
```

**If empty**: File upload isn't working → Check Loopback storage config

**If files exist**: Upload works! Move to Step 3

---

## Step 3: Check Database Has Image Paths

### Check MongoDB Directly

```javascript
// In MongoDB shell or Compass
db.BienImmo.findOne({_id: ObjectId("your-bien-immo-id")})
```

**Expected:**
```json
{
  "_id": ObjectId("..."),
  "typeBien": "appartement",
  "listeImages": [
    "uploads/bien-immos/1733312345678-xyz.jpg"
  ]
}
```

**If `listeImages` is empty or missing**:
- Backend isn't updating the database after upload
- Check Step 4 in LOOPBACK_IMAGE_SETUP.md
- Make sure you're calling `bienImmo.save()` after adding image

---

## Step 4: Check Backend Returns Images in API Response

### Test GET Request

```bash
curl "http://192.168.1.4:3000/bien-immos/your-bien-immo-id"
```

**Expected Response:**
```json
{
  "id": "...",
  "typeBien": "appartement",
  "listeImages": [
    "uploads/bien-immos/1733312345678-xyz.jpg"
  ],
  ...
}
```

**If `listeImages` is empty**: Database issue (see Step 3)

**If `listeImages` is missing from response**: Check Loopback model definition includes this field

---

## Step 5: Check Flutter App Receives Data

### Add Debug Logging to ActivityController

**Edit `lib/controller/activity_controller.dart`**:

```dart
Future<void> fetchUserProperties() async {
  try {
    // ... existing code ...

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      // 🔍 DEBUG: Print full response
      print('=' * 80);
      print('📦 API RESPONSE for user properties:');
      print(jsonList);
      print('=' * 80);

      userProperties.value = jsonList.cast<Map<String, dynamic>>();

      // 🔍 DEBUG: Print each property's images
      for (var property in userProperties) {
        print('🏠 Property: ${property['typeBien']}');
        print('   ID: ${property['_id']}');
        print('   Images: ${property['listeImages']}');
        print('---');
      }

      filteredProperties.value = List.from(userProperties);
      print('✅ Fetched ${userProperties.length} properties');
    }
  } catch (e) {
    print('❌ Error fetching user properties: $e');
  }
}
```

### Run App and Check Console

```bash
flutter run
```

Look for output like:
```
📦 API RESPONSE for user properties:
[{
  _id: 674f0f31a34ecb1c1bef6b6b,
  typeBien: appartement,
  listeImages: [uploads/bien-immos/1733312345678-xyz.jpg],
  ...
}]

🏠 Property: appartement
   ID: 674f0f31a34ecb1c1bef6b6b
   Images: [uploads/bien-immos/1733312345678-xyz.jpg]
```

**If `listeImages` is empty in console**: Backend issue (see Steps 1-4)

**If `listeImages` has data**: Good! Move to Step 6

---

## Step 6: Check Image URL Building

### Add Debug to _getPropertyImage

**Edit `lib/controller/activity_controller.dart`**:

```dart
String _getPropertyImage(Map<String, dynamic> property) {
  try {
    print('🔍 _getPropertyImage called for: ${property['typeBien']}');
    print('   listeImages field: ${property['listeImages']}');

    if (property['listeImages'] != null &&
        property['listeImages'] is List &&
        (property['listeImages'] as List).isNotEmpty) {
      String imagePath = (property['listeImages'] as List).first.toString();
      print('   ✅ Found image path: $imagePath');

      String fullUrl = _buildImageUrl(imagePath);
      print('   🔗 Built full URL: $fullUrl');
      return fullUrl;
    }

    print('   ⚠️ No images - using fallback');
    // ... fallback code
  } catch (e) {
    print('   ❌ Error: $e');
  }
}
```

### Check Console for Image URLs

You should see:
```
🔍 _getPropertyImage called for: appartement
   listeImages field: [uploads/bien-immos/1733312345678-xyz.jpg]
   ✅ Found image path: uploads/bien-immos/1733312345678-xyz.jpg
   🔗 Built full URL: http://192.168.1.4:3000/uploads/bien-immos/1733312345678-xyz.jpg
```

**If URL looks wrong**: Check `ApiConfig.baseUrl` in `lib/configs/api_config.dart`

---

## Step 7: Check Image Actually Accessible

### Test Image URL in Browser

Copy the URL from Step 6 and paste in browser:
```
http://192.168.1.4:3000/uploads/bien-immos/1733312345678-xyz.jpg
```

**If image loads**: Backend serving files correctly! ✅

**If 404**: Backend not serving static files → Check `server/server.js`:
```javascript
server.use('/uploads', server.loopback.static(path.resolve(__dirname, '../uploads')));
```

**If connection refused**: Network issue (firewall, wrong IP)

---

## Step 8: Check Flutter Image Widget

### Add Debug to CachedNetworkImageWidget

**Edit `lib/common/cached_network_image_widget.dart`**:

```dart
@override
Widget build(BuildContext context) {
  print('🖼️ CachedNetworkImageWidget build:');
  print('   URL: $imageUrl');

  // Check if URL is valid
  if (imageUrl == null || imageUrl!.isEmpty) {
    print('   ❌ URL is null or empty');
    return _buildErrorWidget();
  }

  if (!imageUrl!.startsWith('http://') && !imageUrl!.startsWith('https://')) {
    print('   ❌ URL doesn\'t start with http:// or https://');
    return _buildErrorWidget();
  }

  print('   ✅ URL is valid, loading...');

  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) {
        print('   ⏳ Loading image...');
        return _buildPlaceholder();
      },
      errorWidget: (context, url, error) {
        print('   ❌ Image load error: $error');
        return _buildErrorWidget();
      },
      fadeInDuration: const Duration(milliseconds: 300),
    ),
  );
}
```

### Check Console During Image Load

```
🖼️ CachedNetworkImageWidget build:
   URL: http://192.168.1.4:3000/uploads/bien-immos/1733312345678-xyz.jpg
   ✅ URL is valid, loading...
   ⏳ Loading image...
```

**If error appears**: Note the error message for debugging

---

## Step 9: Common Issues & Solutions

### Issue 1: MongoDB ObjectId Format

**Symptom**: Images upload but don't show

**Cause**: MongoDB returns `_id` as `{ "$oid": "..." }` instead of string

**Fix**: Already handled in `ActivityController.getPropertyId()`

### Issue 2: CORS Errors

**Symptom**: Console shows "CORS policy" errors

**Fix**: Add to backend:
```javascript
// server/middleware.json
{
  "initial:before": {
    "compression": {}
  },
  "initial": {
    "cors": {
      "params": {
        "origin": true,
        "credentials": true,
        "maxAge": 86400
      }
    }
  }
}
```

### Issue 3: Relative Paths Not Converting

**Symptom**: Images URL is `"uploads/..."` instead of `"http://..."`

**Fix**: Check `_buildImageUrl()` function in `ActivityController`

### Issue 4: Old Cached Data

**Symptom**: Changes not reflecting

**Fix**:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue 5: Wrong IP Address

**Symptom**: Works on Chrome, fails on phone

**Fix**: Update `lib/configs/api_config.dart` with YOUR PC's IP:
```dart
static const String _localIP = '192.168.1.4'; // Change this!
```

---

## 🚀 Quick Debug Commands

### 1. Check Everything at Once

Run these commands on backend:
```bash
# Check uploads folder
echo "=== Uploads folder ===" && ls -la uploads/bien-immos/

# Check MongoDB (using mongosh)
echo "=== MongoDB data ===" && mongosh your-db-name --eval "db.BienImmo.find({}, {listeImages: 1, typeBien: 1}).pretty()"

# Check if server serves files
echo "=== Test file serving ===" && curl -I http://localhost:3000/uploads/bien-immos/test.jpg
```

### 2. Flutter Debug Output

Add to `main.dart`:
```dart
void main() {
  debugPrint('🚀 App starting with API: ${ApiConfig.baseUrl}');
  runApp(MyApp());
}
```

---

## 📊 Debug Checklist

Use this checklist to track where the issue is:

- [ ] ✅ Backend receives upload request
- [ ] ✅ File saved to `uploads/bien-immos/` directory
- [ ] ✅ MongoDB has `listeImages` field populated
- [ ] ✅ GET /bien-immos/:id returns `listeImages` in response
- [ ] ✅ Flutter app receives `listeImages` data (check console)
- [ ] ✅ `_buildImageUrl()` creates correct full URL
- [ ] ✅ Image URL accessible in browser
- [ ] ✅ `CachedNetworkImageWidget` loads image successfully

**If all checked**: Images should be working! 🎉

**If stuck at any step**: That's where the bug is!

---

## 🆘 Still Not Working?

### Provide These Details for Help:

1. **Flutter console output** (from Step 5)
2. **Image URL** (from Step 6)
3. **Browser test result** (from Step 7)
4. **Backend endpoint response** (from Step 4)
5. **MongoDB data** (from Step 3)

Example issue report:
```
Images not showing after upload

✅ File saved: uploads/bien-immos/123.jpg
✅ MongoDB has: listeImages: ["uploads/bien-immos/123.jpg"]
✅ API returns: { listeImages: [...] }
❌ Flutter builds URL: http://192.168.1.4:3000/uploads/bien-immos/123.jpg
❌ Browser shows: 404 Not Found

→ Issue: Backend not serving static files
```

---

## 💡 Pro Tips

1. **Use network inspector** in Chrome DevTools to see actual image requests
2. **Check Flutter logs** during property creation for upload errors
3. **Test with small image** first (< 1MB) to rule out size issues
4. **Use Postman** to test backend endpoints independently
5. **Clear app cache** if seeing old data: `flutter clean`
