# FitBuddy - Workout Progress Tracker

FitBuddy is a Flutter mobile application designed to help users create, manage, and track their workout programs. It provides features for creating custom workout routines, logging progress, and monitoring performance over time.

## Features

- Create and manage custom workout programs
- Schedule exercises for specific days of the week
- Track workout progress with detailed logging
- View exercise history and performance trends
- Authentication system for secure data storage
- Customizable exercise library

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 3.0 or higher)
- Android Studio / XCode / Visual Studio Code for mobile development
- Git for version control

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/robonec21/fitbuddy_flutter.git
cd fitbuddy
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app with the appropriate environment configuration:

For development:
```bash
flutter run --dart-define=API_URL=http://your-dev-api-url:8080/api
```

For production:
```bash
flutter run --dart-define=API_URL=https://your-production-api-url/api
```

## Authentication

The app uses JWT (JSON Web Token) authentication. Tokens are stored securely using Flutter Secure Storage. The auth flow includes:
- Login
- Sign Up
- Automatic token refresh
- Secure session management

## Environment Setup

The application uses `--dart-define` for environment configuration. This allows for different settings in development and production without committing sensitive data.

### VS Code Launch Configuration

Create `.vscode/launch.json`:
```json
{
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=API_URL=http://your-dev-api-url:8080/api"
      ]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=API_URL=https://your-production-api-url/api"
      ]
    }
  ]
}
```

### Environment Variables

The following environment variables need to be configured:
- `API_URL`: Base URL for the backend API

## Backend Integration

The app requires a running instance of the FitBuddy backend service. The backend repository and setup instructions can be found at:
[FitBuddy Backend Repository](https://github.com/robonec21/fitbuddy)

## Building for Release

1. Set up signing configurations for Android/iOS

2. Build the release version with production configuration:

For Android:
```bash
flutter build apk --release --dart-define=API_URL=https://your-production-api-url/api
```

For iOS:
```bash
flutter build ios --release --dart-define=API_URL=https://your-production-api-url/api
```

## Testing

Run tests with:
```bash
flutter test
```

For integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
