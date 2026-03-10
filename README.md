# Taskly

A modern task management app built with Flutter, featuring Firebase authentication and real-time data sync.

## Features

- User authentication (Email/Password and Google Sign-In)
- Create, edit, and delete tasks
- Mark tasks as complete/incomplete
- Real-time sync with Firebase Realtime Database
- Beautiful UI with animations and Material Design 3

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Firebase Auth** - User authentication
- **Firebase Realtime Database** - Cloud data storage
- **BLoC** - State management
- **Clean Architecture** - Project structure
- **GetIt** - Dependency injection
- **Dartz** - Functional programming utilities

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants
│   ├── errors/         # Error handling
│   ├── theme/          # App theming
│   └── usecases/       # Base usecase
├── features/
│   ├── auth/           # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── tasks/          # Tasks feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   └── widgets/        # Reusable widgets
├── firebase_options.dart
├── injection_container.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.7)
- Firebase project with Authentication and Realtime Database enabled
- Android Studio / VS Code

### Setup

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd todo_app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Email/Password and Google Sign-In authentication
   - Set up Realtime Database
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. Run the app
   ```bash
   flutter run
   ```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^3.8.1 | Firebase initialization |
| firebase_auth | ^5.3.4 | Authentication |
| google_sign_in | ^6.2.2 | Google Sign-In |
| flutter_bloc | ^8.1.3 | State management |
| get_it | ^7.6.4 | Dependency injection |
| dartz | ^0.10.1 | Functional programming |
| http | ^1.1.0 | HTTP requests |
| equatable | ^2.0.5 | Value equality |

## License

This project is for educational purposes.
