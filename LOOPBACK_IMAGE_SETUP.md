# Loopback + MongoDB Image Storage - Complete Guide

## 🎯 Best Practices for Storing Property Images

### Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │ POST /bien-immos/:id/media
         │ (multipart/form-data)
         ▼
┌─────────────────────────────────┐
│  Loopback Backend               │
│                                 │
│  ┌──────────────────────────┐  │
│  │ Storage Component        │  │
│  │ (loopback-component-     │  │
│  │  storage)                │  │
│  └──────────┬───────────────┘  │
│             │                   │
│             ▼                   │
│  ┌──────────────────────────┐  │
│  │ Filesystem               │  │
│  │ /uploads/bien-immos/     │  │
│  │   ├── 123.jpg            │  │
│  │   ├── 456.jpg            │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ MongoDB                  │  │
│  │                          │  │
│  │ BienImmo {              │  │
│  │   _id: "...",           │  │
│  │   listeImages: [        │  │
│  │     "uploads/123.jpg"   │  │
│  │   ]                     │  │
│  │ }                       │  │
│  └──────────────────────────┘  │
└─────────────────────────────────┘
```

---

## ⚠️ What NOT to Do

### ❌ DON'T Store Images Directly in MongoDB

```javascript
// BAD - This will make your database huge and slow!
{
  _id: "abc123",
  imageData: "<base64 string of 5MB image>",  // ❌ NO!
  typeBien: "appartement"
}
```

**Why it's bad:**
- MongoDB documents limited to 16MB
- Slow queries
- Inefficient backups
- Poor performance

---

## ✅ Correct Approach: Store Files on Disk, Paths in DB

### Step 1: Install Loopback Storage Component

```bash
npm install loopback-component-storage
```

### Step 2: Create Storage DataSource

**`server/datasources.json`**:
```json
{
  "storage": {
    "name": "storage",
    "connector": "loopback-component-storage",
    "provider": "filesystem",
    "root": "./uploads",
    "maxFileSize": 52428800
  }
}
```

### Step 3: Create Container Model

**`common/models/container.json`**:
```json
{
  "name": "Container",
  "base": "Model",
  "properties": {},
  "validations": [],
  "relations": {},
  "acls": [],
  "methods": {}
}
```

**`common/models/container.js`**:
```javascript
module.exports = function(Container) {
  // Model is provided by loopback-component-storage
};
```

**`server/model-config.json`**:
```json
{
  "Container": {
    "dataSource": "storage",
    "public": true
  }
}
```

### Step 4: Create Custom BienImmo Media Endpoint

**`common/models/bien-immo.js`**:
```javascript
module.exports = function(BienImmo) {

  /**
   * Upload image to a specific BienImmo
   * POST /bien-immos/:id/media
   */
  BienImmo.uploadMedia = function(id, req, res, cb) {
    const Container = BienImmo.app.models.Container;
    const containerName = 'bien-immos'; // Folder name

    // Ensure container exists
    Container.getContainer(containerName, (err, container) => {
      if (err && err.code === 'ENOENT') {
        // Create container if it doesn't exist
        Container.createContainer({name: containerName}, (err) => {
          if (err) return cb(err);
          uploadFile();
        });
      } else if (err) {
        return cb(err);
      } else {
        uploadFile();
      }
    });

    function uploadFile() {
      Container.upload(req, res, {
        container: containerName,
        getFilename: function(file, req, res) {
          // Generate unique filename
          const timestamp = Date.now();
          const originalName = file.name;
          const extension = originalName.split('.').pop();
          return `${timestamp}-${Math.random().toString(36).substring(7)}.${extension}`;
        }
      }, (err, fileObj) => {
        if (err) return cb(err);

        // File uploaded successfully
        const files = fileObj.files.file;
        const uploadedFile = Array.isArray(files) ? files[0] : files;

        // Build image URL/path
        const imagePath = `uploads/${containerName}/${uploadedFile.name}`;

        // Add to BienImmo's listeImages
        BienImmo.findById(id, (err, bienImmo) => {
          if (err) return cb(err);
          if (!bienImmo) {
            return cb(new Error('BienImmo not found'));
          }

          // Initialize listeImages if it doesn't exist
          if (!bienImmo.listeImages) {
            bienImmo.listeImages = [];
          }

          // Add new image path
          bienImmo.listeImages.push(imagePath);

          // Save to database
          bienImmo.save((err, updated) => {
            if (err) return cb(err);

            // Return success response
            cb(null, {
              success: true,
              url: imagePath,
              filename: uploadedFile.name,
              container: containerName,
              bienImmo: updated
            });
          });
        });
      });
    }
  };

  // Register the remote method
  BienImmo.remoteMethod('uploadMedia', {
    description: 'Upload an image for this BienImmo',
    accepts: [
      {arg: 'id', type: 'string', required: true, http: {source: 'path'}},
      {arg: 'req', type: 'object', http: {source: 'req'}},
      {arg: 'res', type: 'object', http: {source: 'res'}}
    ],
    returns: {arg: 'result', type: 'object', root: true},
    http: {path: '/:id/media', verb: 'post'}
  });

  /**
   * Get image URL helper
   */
  BienImmo.getImageUrl = function(imagePath, req) {
    if (!imagePath) return null;

    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Build full URL
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    return `${baseUrl}/${imagePath}`;
  };

  /**
   * Delete image from BienImmo
   * DELETE /bien-immos/:id/media/:filename
   */
  BienImmo.deleteMedia = function(id, filename, cb) {
    const Container = BienImmo.app.models.Container;
    const containerName = 'bien-immos';

    // Remove from filesystem
    Container.removeFile(containerName, filename, (err) => {
      if (err && err.code !== 'ENOENT') {
        console.error('Error deleting file:', err);
        // Continue even if file deletion fails
      }

      // Remove from BienImmo's listeImages
      BienImmo.findById(id, (err, bienImmo) => {
        if (err) return cb(err);
        if (!bienImmo) {
          return cb(new Error('BienImmo not found'));
        }

        // Remove the image path
        const imagePath = `uploads/${containerName}/${filename}`;
        bienImmo.listeImages = (bienImmo.listeImages || [])
          .filter(img => !img.includes(filename));

        bienImmo.save((err, updated) => {
          if (err) return cb(err);
          cb(null, {success: true, bienImmo: updated});
        });
      });
    });
  };

  BienImmo.remoteMethod('deleteMedia', {
    description: 'Delete an image from this BienImmo',
    accepts: [
      {arg: 'id', type: 'string', required: true, http: {source: 'path'}},
      {arg: 'filename', type: 'string', required: true, http: {source: 'path'}}
    ],
    returns: {arg: 'result', type: 'object', root: true},
    http: {path: '/:id/media/:filename', verb: 'delete'}
  });
};
```

### Step 5: Serve Static Files

**`server/middleware.json`**:
```json
{
  "files": {
    "loopback#static": {
      "params": "$!../uploads"
    }
  }
}
```

Or in **`server/server.js`**:
```javascript
const path = require('path');

module.exports = function(server) {
  // Serve static uploads
  server.use('/uploads', server.loopback.static(path.resolve(__dirname, '../uploads')));

  // Start the server
  server.start = function() {
    return server.listen(function() {
      server.emit('started');
      const baseUrl = server.get('url').replace(/\/$/, '');
      console.log('Web server listening at: %s', baseUrl);

      if (server.get('loopback-component-explorer')) {
        const explorerPath = server.get('loopback-component-explorer').mountPath;
        console.log('Browse your REST API at %s%s', baseUrl, explorerPath);
      }
    });
  };
};
```

### Step 6: Update BienImmo Model Schema

**`common/models/bien-immo.json`**:
```json
{
  "name": "BienImmo",
  "base": "PersistedModel",
  "properties": {
    "typeBien": {
      "type": "string",
      "required": true
    },
    "listeImages": {
      "type": "array",
      "default": [],
      "description": "Array of image paths (e.g., ['uploads/bien-immos/123.jpg'])"
    },
    "nombrePiecesTotal": {
      "type": "number"
    }
    // ... other properties
  }
}
```

---

## 🧪 Testing the Setup

### Test Image Upload

```bash
# Create a BienImmo first
curl -X POST http://localhost:3000/bien-immos \
  -H "Content-Type: application/json" \
  -d '{
    "typeBien": "appartement",
    "nombrePiecesTotal": 3
  }'

# Response: { "id": "abc123", ... }

# Upload an image
curl -X POST http://localhost:3000/bien-immos/abc123/media \
  -F "file=@/path/to/image.jpg"

# Response:
# {
#   "success": true,
#   "url": "uploads/bien-immos/1733312345678-xyz.jpg",
#   "filename": "1733312345678-xyz.jpg",
#   "bienImmo": {
#     "id": "abc123",
#     "listeImages": ["uploads/bien-immos/1733312345678-xyz.jpg"]
#   }
# }
```

### Test Image Access

```bash
# Access uploaded image
curl http://localhost:3000/uploads/bien-immos/1733312345678-xyz.jpg

# Should return the image file
```

### Test BienImmo Retrieval

```bash
curl http://localhost:3000/bien-immos/abc123

# Response:
# {
#   "id": "abc123",
#   "typeBien": "appartement",
#   "listeImages": ["uploads/bien-immos/1733312345678-xyz.jpg"],
#   ...
# }
```

---

## 🔍 Debugging Checklist

### 1. Check if uploads directory exists
```bash
ls -la uploads/bien-immos/
```

### 2. Check file permissions
```bash
chmod -R 755 uploads/
```

### 3. Check Loopback logs
```javascript
// In common/models/bien-immo.js
console.log('📸 Upload request received for BienImmo:', id);
console.log('📁 File uploaded:', uploadedFile);
console.log('💾 Saved to DB:', imagePath);
```

### 4. Check MongoDB data
```javascript
// MongoDB shell
db.BienImmo.findOne({_id: ObjectId("abc123")})

// Should show:
// {
//   _id: ObjectId("abc123"),
//   listeImages: ["uploads/bien-immos/1733312345678-xyz.jpg"]
// }
```

---

## 📱 Flutter Integration

Your Flutter app is already configured correctly! It:
1. ✅ Uploads to `POST /bien-immos/:id/media`
2. ✅ Expects response with `url` or `path` field
3. ✅ Builds full URLs from relative paths
4. ✅ Displays with caching

**Just make sure your backend returns**:
```json
{
  "url": "uploads/bien-immos/123.jpg"
}
```

---

## 🚀 Production Considerations

### 1. Use CDN for Images
```javascript
// Instead of local storage, use S3/Cloudinary
{
  "storage": {
    "connector": "loopback-component-storage",
    "provider": "amazon",
    "key": "YOUR_AWS_KEY",
    "keyId": "YOUR_AWS_KEY_ID",
    "bucket": "your-bucket-name"
  }
}
```

### 2. Add Image Processing
```javascript
const sharp = require('sharp');

// Resize and optimize before saving
await sharp(inputPath)
  .resize(1200, 800, { fit: 'inside' })
  .jpeg({ quality: 80 })
  .toFile(outputPath);
```

### 3. Add Security
```javascript
// Limit file types
accepts: [
  {arg: 'req', type: 'object', http: {source: 'req'}},
],
// In implementation:
const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
if (!allowedTypes.includes(file.type)) {
  return cb(new Error('Invalid file type'));
}
```

---

## 📊 File Structure

```
your-loopback-app/
├── common/
│   └── models/
│       ├── bien-immo.js       ← Custom upload methods
│       ├── bien-immo.json
│       ├── container.js
│       └── container.json
├── server/
│   ├── datasources.json       ← Storage config
│   ├── middleware.json        ← Static files
│   ├── model-config.json
│   └── server.js              ← Static file serving
└── uploads/                   ← Created automatically
    └── bien-immos/
        ├── 1733312345678-abc.jpg
        └── 1733312346789-xyz.jpg
```

---

## ✅ Quick Start Commands

```bash
# 1. Install storage component
npm install loopback-component-storage

# 2. Create uploads directory
mkdir -p uploads/bien-immos

# 3. Add storage datasource (see Step 2 above)

# 4. Add container model (see Step 3 above)

# 5. Update BienImmo model (see Step 4 above)

# 6. Configure static serving (see Step 5 above)

# 7. Restart server
node .

# 8. Test with Flutter app!
```

---

## 🆘 Common Issues

### Issue: "Container not found"
**Fix**: Auto-create in uploadMedia function (see Step 4)

### Issue: "ENOENT: no such file or directory"
**Fix**: `mkdir -p uploads/bien-immos`

### Issue: "404 when accessing image URL"
**Fix**: Check static middleware configuration (Step 5)

### Issue: "Images not showing in Flutter app"
**Fix**:
1. Check backend returns `url` field
2. Verify `listeImages` array is populated
3. Check console logs in Flutter app
4. Ensure phone and PC on same network

---

## 📚 Resources

- [Loopback Storage Component Docs](https://loopback.io/doc/en/lb3/Storage-component.html)
- [Loopback 4 File Upload Guide](https://loopback.io/doc/en/lb4/File-upload-download.html)
- [MongoDB GridFS (alternative)](https://www.mongodb.com/docs/manual/core/gridfs/) - For files > 16MB
