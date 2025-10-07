# Firebase Setup Instructions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `pv-system-monitor`
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

## Step 3: Enable Realtime Database

1. In Firebase Console, go to "Realtime Database"
2. Click "Create Database"
3. Choose location (e.g., us-central1)
4. Start in "Test mode" for development
5. Click "Enable"

## Step 4: Add Flutter App

### For Android:
1. Click "Add app" → Android icon
2. Enter package name: `com.example.pv_system_monitor`
3. Download `google-services.json`
4. Place it in `android/app/` directory

### For iOS:
1. Click "Add app" → iOS icon
2. Enter bundle ID: `com.example.pvSystemMonitor`
3. Download `GoogleService-Info.plist`
4. Add it to iOS project in Xcode

## Step 5: Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase project configuration:

```dart
// Get these values from Firebase Console → Project Settings → General
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-android-api-key',
  appId: 'your-android-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  databaseURL: 'https://your-project-id-default-rtdb.region.firebasedatabase.app',
  storageBucket: 'your-project-id.appspot.com',
);
```

## Step 6: Set Up Database Structure

In Firebase Console → Realtime Database, import this JSON structure:

```json
{
  "system": {
    "currentValue": {
      "current": -16.5,
      "humidity": 0,
      "light": 0,
      "power": 0,
      "temperature": 0,
      "timestamp": 120,
      "voltage": 0
    },
    "history": {
      "6489": {
        "current": 3.3,
        "humidity": 33,
        "light": 3033,
        "power": 775.5,
        "temperature": 31,
        "timestamp": 6,
        "voltage": 235
      },
      "6559": {
        "current": 2.8,
        "humidity": 35,
        "light": 2800,
        "power": 650.0,
        "temperature": 29,
        "timestamp": 10,
        "voltage": 230
      }
    }
  }
}
```

## Step 7: Configure Database Rules

Set these rules for development (make them more restrictive for production):

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

## Step 8: Test the App

1. Run `flutter pub get`
2. Run `flutter run`
3. Create a test account
4. Verify data is loading from Firebase

## Production Considerations

- Update database rules for production security
- Enable App Check for additional security
- Set up proper error monitoring
- Configure backup and recovery
