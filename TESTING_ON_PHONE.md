# 📱 Testing Flutter App on Your Phone

This guide helps you test your MaxiiM Flutter app on your physical phone while keeping the backend on your PC.

---

## 🎯 Quick Setup (3 Steps)

### Step 1: Find Your PC's Local IP Address

**On Windows:**
```bash
ipconfig
```

Look for **"IPv4 Address"** under your active network adapter (WiFi or Ethernet).

Example output:
```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

Your IP is: **192.168.1.100** (yours will be different)

---

### Step 2: Update the IP in Flutter App

1. Open: `lib/configs/api_config.dart`

2. Change this line:
   ```dart
   static const String _localIP = '127.0.0.1'; // ⬅️ CHANGE THIS
   ```

3. To your PC's IP:
   ```dart
   static const String _localIP = '192.168.1.100'; // Your actual IP
   ```

4. Save the file

---

### Step 3: Make Your Backend Listen on Network

Your backend needs to listen on **0.0.0.0** (not just localhost) so your phone can connect.

**If using Node.js/LoopBack:**

Change from:
```javascript
app.listen(3000, 'localhost')  // ❌ Only local
```

To:
```javascript
app.listen(3000, '0.0.0.0')     // ✅ Network accessible
```

Or simply:
```javascript
app.listen(3000)                // ✅ Also works
```

**Restart your backend server** after this change.

---

## 🔌 Connect Your Phone

### Option A: USB Cable (Recommended)
1. Connect phone to PC via USB
2. Enable **USB Debugging** on your phone:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"
3. Run: `flutter devices` (should show your phone)
4. Run: `flutter run` (select your phone)

### Option B: WiFi
1. Ensure phone and PC are on the **same WiFi network**
2. Run: `flutter run` and select your phone

---

## ✅ Verify It's Working

When you run the app, you should see in the console:

```
=================================
📡 API Configuration
=================================
Base URL: http://192.168.1.100:3000
=================================
```

If you see `http://127.0.0.1:3000`, you forgot to update `api_config.dart`!

---

## 🐛 Troubleshooting

### Problem: "Connection refused" or "Network error"

**Solution 1:** Check if backend is listening on network
```bash
# On your PC, run:
netstat -an | findstr :3000

# You should see:
# TCP    0.0.0.0:3000         LISTENING  ✅ Good
# NOT:
# TCP    127.0.0.1:3000       LISTENING  ❌ Local only
```

**Solution 2:** Check Windows Firewall
- Windows may be blocking port 3000
- Allow Node.js through firewall
- Or temporarily disable firewall for testing

**Solution 3:** Verify IP is correct
```bash
# Ping your PC from your phone's browser:
http://192.168.1.100:3000

# Should show your API response or "Cannot GET /"
```

---

### Problem: App still connecting to localhost

**Solution:** You updated the IP but didn't restart the app
1. Stop the app completely
2. Run: `flutter clean`
3. Run: `flutter run` again

---

### Problem: Phone not detected

**Solution:**
1. Enable USB debugging (see above)
2. Install phone drivers (automatically on most Windows)
3. Authorize debugging on phone when prompted
4. Run: `flutter doctor` to check setup

---

## 🌐 Testing Checklist

- [ ] Found your PC's IP address
- [ ] Updated `lib/configs/api_config.dart` with your IP
- [ ] Backend listening on `0.0.0.0:3000`
- [ ] Phone on same WiFi as PC
- [ ] Restarted Flutter app
- [ ] Console shows correct IP in API config
- [ ] Can login from phone
- [ ] Can create/view properties from phone

---

## 📝 Important Notes

1. **Change IP back for web testing:**
   - For Chrome/web: use `127.0.0.1`
   - For phone: use your PC's IP (e.g., `192.168.1.100`)

2. **IP may change:**
   - If you disconnect/reconnect to WiFi, your IP might change
   - Re-run `ipconfig` and update `api_config.dart` if needed

3. **Security:**
   - This setup is for **development only**
   - Don't use this in production
   - Use proper HTTPS and domain names for production

---

## 🚀 Quick Switch Between Environments

In `api_config.dart`, you can quickly switch:

```dart
// For web/desktop testing:
static const String _localIP = '127.0.0.1';

// For phone testing:
static const String _localIP = '192.168.1.100';  // Your PC's IP

// For production (later):
static const String _localIP = 'api.maxiim.com';
```

Just comment/uncomment the one you need!

---

## 🎉 Success!

If you can:
- ✅ Open the app on your phone
- ✅ See the API configuration in console
- ✅ Login successfully
- ✅ View and create properties

**You're all set!** 🎊

---

Need help? Check the console for detailed error messages and logs!
