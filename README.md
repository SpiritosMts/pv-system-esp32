# PV System Monitor

A Flutter application for monitoring photovoltaic (PV) system data in real-time with Firebase integration, authentication, and beautiful animations.

## Features

- **Real-time Data Monitoring**: Live updates from Firebase Realtime Database
- **Authentication System**: Secure login and registration with Firebase Auth
- **Interactive Dashboard**: Beautiful cards showing current system values
- **Historical Analytics**: Charts and graphs for data analysis
- **Smooth Animations**: Engaging UI with flutter_animate
- **Responsive Design**: Works on both light and dark themes
- **Clean Architecture**: Well-organized code with Provider state management

## Screenshots

The app displays real-time data for:
- Current (A)
- Voltage (V) 
- Power (W)
- Temperature (°C)
- Humidity (%)
- Light intensity (lux)

## Firebase Setup

Before running the app, you need to configure Firebase:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Enable Realtime Database
4. Update `lib/firebase_options.dart` with your Firebase configuration
5. Set up your database structure like this:

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
      }
    }
  }
}
```

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase (see Firebase Setup above)
4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **firebase_core**: Firebase SDK core
- **firebase_auth**: Authentication
- **firebase_database**: Realtime Database
- **provider**: State management
- **google_fonts**: Custom fonts
- **flutter_animate**: Smooth animations
- **fl_chart**: Beautiful charts
- **intl**: Date formatting

## Architecture

The app follows a clean architecture pattern:

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── utils/           # Utilities and themes
└── main.dart        # App entry point
```

## Usage

1. **Authentication**: Create an account or sign in
2. **Dashboard**: View real-time system data
3. **History**: Analyze historical data with interactive charts
4. **Settings**: Manage account and app preferences

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
