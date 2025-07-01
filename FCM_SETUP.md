# 🔥 Firebase Cloud Messaging (FCM) Setup Guide

## 📋 Overview
Complete guide for setting up Firebase Cloud Messaging in the MartFury Flutter app, including troubleshooting common issues and ensuring real FCM tokens are generated.

## 🎯 Current Status
- ✅ Firebase dependencies added to pubspec.yaml
- ✅ Android build configuration updated
- ✅ iOS build configuration ready
- ✅ FCM implementation completed with error handling
- ✅ Fallback token system working for development
- ⚠️ **Action Required**: Get real Firebase configuration files

## 🚨 Common Issues & Solutions

### Issue 1: "APNS token has not been set yet" (iOS)
**Status**: ✅ **SOLVED** - Enhanced error handling implemented

**What was fixed**:
- Added proper APNS token checking for iOS
- Implemented retry logic for APNS token availability
- Added graceful fallback when APNS is not available
- iOS simulators generate fallback tokens (expected behavior)

### Issue 2: "Invalid FCM registration token" (API Error)
**Root Cause**: App generates fallback development tokens instead of real FCM tokens

**Fallback Token Example**:
```
dev_ios_1B54112A-7390-48B7-92DE-F83A15E2F6F1_1.0.0
```

**Real FCM Token Example**:
```
eK7_Vx9mTUGq4H8j2N5pL3:APA91bF...very-long-string...xyz123
```

## 🔧 Complete Setup Instructions

### Step 1: Firebase Console Setup
1. **Go to**: https://console.firebase.google.com/
2. **Select project**: `martfury-d6732`
3. **Navigate to**: Project Settings (gear icon)

### Step 2: Add Android App (Required for Real Tokens)
1. **Click**: Add app → Android (📱 icon)
2. **Package name**: `com.example.martfury`
3. **App nickname**: `MartFury Android` (optional)
4. **Debug signing certificate SHA-1**: Leave blank for now
5. **Click**: Register app
6. **Download**: `google-services.json`
7. **Replace**: `android/app/google-services.json` with downloaded file

**Current Android config has placeholder values**:
```json
{
  "mobilesdk_app_id": "1:482507114156:android:ANDROID_APP_ID_NEEDED", // ❌ Placeholder
  "client_id": "482507114156-OAUTH_CLIENT_ID.apps.googleusercontent.com" // ❌ Placeholder
}
```

**Real Android config should have**:
```json
{
  "client_info": {
    "mobilesdk_app_id": "1:482507114156:android:abc123def456", // ✅ Real ID
    "android_client_info": {
      "package_name": "com.example.martfury"
    }
  },
  "oauth_client": [{
    "client_id": "482507114156-realclientid.apps.googleusercontent.com", // ✅ Real ID
    "client_type": 3
  }]
}
```

### Step 3: Add/Verify iOS App
1. **Check if iOS app exists** with bundle ID `com.example.martfury`
2. **If not exists**:
   - Click Add app → iOS
   - Bundle ID: `com.example.martfury`
   - App nickname: `MartFury iOS`
   - Register app
3. **Download**: `GoogleService-Info.plist`
4. **Replace**: `ios/Runner/GoogleService-Info.plist`

### Step 4: Add iOS Configuration to Xcode Project
**Critical**: The `GoogleService-Info.plist` file must be added to the Xcode project, not just placed in the folder.

**Option 1: Add via Xcode (Recommended)**
1. **Open**: `open ios/Runner.xcworkspace`
2. **Right-click** on `Runner` folder in Xcode
3. **Select**: "Add Files to Runner"
4. **Navigate to**: `ios/Runner/GoogleService-Info.plist`
5. **IMPORTANT**: Check "Add to target: Runner"
6. **Click**: "Add"

### Step 5: Enable iOS Push Notifications in Xcode
1. **Select**: Runner project
2. **Go to**: Runner target → Signing & Capabilities
3. **Click**: + Capability
4. **Add**: Push Notifications
5. **Add**: Background Modes
   - Enable: Background processing
   - Enable: Remote notifications

### Step 6: Enable Firebase Services
In Firebase Console:
- ✅ **Cloud Messaging (FCM)** - for push notifications
- ✅ **Authentication** - if using Firebase Auth
- ✅ **Firestore/Realtime Database** - if using Firebase database

For iOS: Upload your APNs certificate or key in Project Settings > Cloud Messaging

## 🧪 Testing the Setup

### Clean and Run
```bash
flutter clean
cd ios && pod install && cd ..
flutter run
```

### Expected Output (Success)
```
✅ Firebase initialized successfully
✅ FCM notifications initialized successfully
✅ APNS token available (iOS physical device)
✅ FCM token obtained: eK7_Vx9mTUGq4H8j2N5pL3:APA91b...
✅ Device token registered successfully
```

### Expected Output (iOS Simulator - Normal)
```
✅ Firebase initialized successfully
✅ FCM notifications initialized successfully
⚠️ APNS token not available yet, waiting...
⚠️ APNS token still not available. This is normal on simulators.
📱 For push notifications to work, test on a physical iOS device.
🔧 Generated fallback token for development: dev_ios_...
✅ Device token registered successfully
```

## 📱 Platform-Specific Behavior

### iOS Simulator
- ⚠️ **APNS not available** (Apple limitation)
- ✅ **Fallback token generated** for development
- ✅ **App works normally** with mock notifications
- 💡 **For real push notifications**: Test on physical iOS device

### iOS Physical Device
- ✅ **Full APNS support**
- ✅ **Real FCM tokens**
- ✅ **Actual push notifications**
- **Requires**: Notification permissions enabled

### Android (Emulator & Device)
- ✅ **Full FCM support** on both emulator and device
- ✅ **Real push notifications** work
- **Requires**: Real `google-services.json` from Firebase Console

## 🔍 Troubleshooting

### iOS Permission Issues
**Check iPhone Permissions**:
1. **Settings** → **Notifications** → **MartFury**
2. **Turn ON**: "Allow Notifications"
3. **Enable**: Alerts, Sounds, Badges
4. **If denied**: Delete and reinstall the app

### Still Getting Fallback Tokens?
1. **Verify**: Real `google-services.json` downloaded from Firebase Console
2. **Check**: Android app properly registered with package `com.example.martfury`
3. **Test**: On physical iOS device instead of simulator
4. **Ensure**: iOS app added to Xcode project correctly

### Firebase Initialization Fails
1. **Verify**: `GoogleService-Info.plist` added to Xcode project (not just folder)
2. **Check**: Bundle ID matches exactly: `com.example.martfury`
3. **Confirm**: Firebase project ID is `martfury-d6732`

## 📁 File Structure After Setup
```
android/app/google-services.json          ← Real file from Firebase Console
ios/Runner/GoogleService-Info.plist       ← Real file from Firebase Console (added to Xcode)
firebase-service-account-key.json         ← Server-side key (for backend)
```

## 🔑 Important Notes

### File Types
- **Service Account Key** (`firebase-service-account-key.json`): For server-side/backend use
- **Client Config Files** (`google-services.json`, `GoogleService-Info.plist`): For mobile app use
- **Never confuse these two** - they serve different purposes

### Token Types
- **Real FCM Token**: 100+ characters, contains colon (:), works with FCM v1 API
- **Fallback Token**: ~50 characters, starts with `dev_`, development only

### Production Readiness
- **Development**: Fallback tokens allow testing app flow
- **Production**: Only real FCM tokens work for actual notifications
- **Testing**: Use Firebase Console to send test notifications to real devices

## 🎯 Priority Action Plan

### Immediate Steps
1. **Add Android app** to Firebase project
2. **Download real** `google-services.json`
3. **Replace placeholder** config file
4. **Test on Android** device/emulator for real tokens

### iOS Steps
1. **Test on physical** iOS device
2. **Verify notification** permissions
3. **Ensure Xcode** project includes `GoogleService-Info.plist`

### Verification
1. **Check token format** in debug logs
2. **Test FCM v1 API** with real tokens
3. **Send test notification** via Firebase Console

## 🎉 Success Indicators

Once properly configured:
- ✅ FCM v1 API requests succeed
- ✅ Push notifications delivered to devices
- ✅ Real FCM tokens generated (not fallback)
- ✅ No "invalid registration token" errors
- ✅ Production-ready implementation

**Your FCM implementation is solid - you just need real configuration files and tokens!**
