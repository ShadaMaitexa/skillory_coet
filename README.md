# skillory_coet

A new Flutter project.

## Collaboration & Versions

This project is configured to be compatible with multiple Flutter versions (from **3.3.4** up to the latest stable).

### Handling Flutter Versions
If you and your collaborators are using different Flutter versions, please follow these guidelines:

1.  **SDK Constraints**: The `pubspec.yaml` has been updated with a wide SDK range (`>=2.18.2 <4.0.0`) to support both Dart 2 (Flutter 3.3.x) and Dart 3.
2.  **Dependencies**: Package versions use flexible ranges. Running `flutter pub get` will resolve the highest compatible version for your specific Flutter SDK.
3.  **FVM (Recommended)**: To ensure everyone is on the same page, we recommend using [FVM (Flutter Version Management)](https://fvm.app/).
    *   The project includes an `.fvmrc` pinning the version to `3.22.1`.
    *   To use it, run `fvm use 3.22.1` and then use `fvm flutter` instead of `flutter`.

## Getting Started

This project is a starting point for a Flutter application.
...

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
