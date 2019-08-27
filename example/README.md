# Example for flutter_native_splash

This is a brand new Flutter project created with `flutter create`.

`pubspec.yaml`:

```yaml
name: example
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.1.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^0.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_native_splash: ^0.1.5

flutter_native_splash:
  image: assets/splash.png
  color: "42a5f5"

flutter:
  uses-material-design: true
```

And then:
```
flutter pub get
flutter pub pub run flutter_native_splash:create
```
