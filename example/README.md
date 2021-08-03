# Example for flutter_native_splash

A new Flutter application for testing a splash screen.

## Getting Started

This is Flutter's example application.  Run it now and you will see that it has Flutter's default white splash screen, followed by a secondary Flutter splash screen that is displayed after Flutter loads while the app is loading resources.

The pubspec.yaml file has been modified to add a color and icon to the splash screen.  To apply these modification, run the following command in the terminal:

```
flutter pub get
flutter pub run flutter_native_splash:create
```

Or, to try specifying a config by setting the path, run the following command in the terminal:

```
flutter pub get
flutter pub run flutter_native_splash:create --path=red.yaml
```

The updated splash screen will now appear when you run the app, followed by the secondary splash screen.

Note that with a default configuration, Android has a momentary fade artifact between the native splash and secondary splash screens.  In this example, the `android/app/src/main/java/com/example/example/MainActivity.java` has been modified to remove this fade artifact.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
