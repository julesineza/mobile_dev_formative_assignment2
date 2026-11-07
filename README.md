# CampusCare

CampusCare is a Flutter application for reporting and tracking campus issues.
Students can submit reports, view their reports, and explore issues. Staff
members can review and update reported issues.

## Requirements

Install the following before starting:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or Xcode
- An Android emulator, iOS simulator, or physical device
- A Firebase project
- An Appwrite project for report images

Check that Flutter is installed correctly:

```bash
flutter doctor
```

## Setup

1. Clone the project and open its folder:

   ```bash
   git clone <repository-url>
   cd mobile_dev_formative_assignment2
   ```

2. Install the Flutter packages:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   - Create a Firebase project.
   - Enable Email/Password sign-in in Firebase Authentication.
   - Create a Firestore database.
   - Add your Android and iOS apps to the Firebase project.
   - Download the platform configuration files and place them in the usual
     Android and iOS locations.
   - Update `lib/firebase_options.dart` if you are using a different Firebase
     project.

4. Configure Appwrite image storage:

   - Create an Appwrite project.
   - Create a storage bucket.
   - Allow file creation for users or anonymous users.
   - Update `env.json` with your Appwrite endpoint, project ID, and bucket ID.

   The required keys are:

   ```json
   {
     "APPWRITE_ENDPOINT": "https://your-appwrite-endpoint/v1",
     "APPWRITE_PROJECT_ID": "your-project-id",
     "bucketID": "your-bucket-id"
   }
   ```

## Running the application

1. List the devices available to Flutter:

   ```bash
   flutter devices
   ```

2. Start an Android emulator or iOS simulator, or connect a physical device.

3. Run the application:

   ```bash
   flutter run
   ```

   To run on a specific device, use its device ID:

   ```bash
   flutter run -d <device-id>
   ```

   For example:

   ```bash
   flutter run -d chrome
   ```

4. While the application is running:

   - Press `r` to hot reload after changing code.
   - Press `R` to hot restart the application.
   - Press `q` to stop the application.

To build the application without starting it:

```bash
flutter build apk       # Android APK
flutter build ios       # iOS application
flutter build web       # Web application
```

## Dependencies

The application uses these runtime dependencies:

| Dependency | Purpose |
|---|---|
| `flutter` | Flutter framework |
| `cupertino_icons` | iOS-style icons |
| `firebase_core` | Connects the application to Firebase |
| `cloud_firestore` | Stores users and campus issue reports |
| `firebase_auth` | Handles account registration and sign-in |
| `provider` | Manages application and screen state |
| `image_picker` | Selects images from the camera or gallery |
| `intl` | Formats dates and other values |
| `uuid` | Generates unique identifiers |
| `appwrite` | Uploads report images to Appwrite Storage |
| `flutter_image_compress` | Compresses images before uploading |

Development dependencies:

| Dependency | Purpose |
|---|---|
| `flutter_test` | Unit and widget testing |
| `integration_test` | End-to-end application testing |
| `flutter_lints` | Dart and Flutter lint rules |

The exact package versions are defined in `pubspec.yaml`. Run this command
after changing dependencies:

```bash
flutter pub get
```

## Accounts

Student accounts must use an email ending in `@alustudent.com` and must verify
their email before signing in.

Staff accounts require the staff access code shown in
`lib/core/constants/staff_access.dart`. Staff accounts do not require email
verification.

## Testing

Run the unit tests with:

```bash
flutter test
```

Run the integration test on a connected device or emulator with:

```bash
flutter test integration_test/app_test.dart
```

## Common commands

```bash
flutter pub get       # Install dependencies
flutter analyze       # Check the code
flutter test          # Run tests
flutter run           # Run the application
```
