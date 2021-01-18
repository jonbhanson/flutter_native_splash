# flutter_native_splash
[![pub package](https://img.shields.io/pub/v/flutter_native_splash)](https://pub.dev/packages/flutter_native_splash)
[![Build Status](https://img.shields.io/travis/henriquearthur/flutter_native_splash)](https://travis-ci.org/henriquearthur/flutter_native_splash)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](https://makeapullrequest.com)

Automatically generates native code for adding splash screens in Android and iOS. Customize with specific platform, background color and splash image.

<p>
  <img src="https://raw.githubusercontent.com/henriquearthur/flutter_native_splash/master/splash_demo.gif" width="250" height="443"  />
</p>

## Usage
First, add `flutter_native_splash` as a dev dependency in your pubspec.yaml file. You should add the package to `dev_dependencies` because you don't need this plugin in your APK.

```yaml
dev_dependencies:
  flutter_native_splash: ^0.2.7
```

Don't forget to `flutter pub get`.

### 1. Setting the splash screen
Add your settings to your project's `pubspec.yaml` file or create a file in your root project folder named `flutter_native_splash.yaml` with your settings.

```yaml
flutter_native_splash:
  color: "#42a5f5"  # required parameter
  image: assets/images/splash.png  # optional parameter
  color_dark: "#042a49"  # required if image_dark parameter is used
  image_dark: assets/images/splash-invert.png  # optional parameter
```

* Images must be `png` files.

To avoid creating a splash screen for a specific platform, `android` or `ios` may be set to `false`.
```yaml
flutter_native_splash:
  color: "#42a5f5"
  android: false
```

To stretch the image(s) to fill the screen, use `fill` parameter. ([`Gravity=fill`](https://developer.android.com/reference/android/view/Gravity#FILL) on Android, not yet implemented for iOS).

```yaml
flutter_native_splash:
  color: "#42a5f5"
  image: assets/images/splash.png
  fill: true
```

To display the notification bar on Android, use the `android_disable_fullscreen` parameter.
```yaml
flutter_native_splash:
  color: "#42a5f5"
  android_disable_fullscreen: true
```

If you have changed the name(s) of your info.plist file(s), you can specify the filename(s) with the `info_plist_files` parameter:
```yaml
flutter_native_splash:
  color: "#42a5f5"
  info_plist_files:
    - 'ios/Runner/Info-Debug.plist'
    - 'ios/Runner/Info-Release.plist'
```

### 2. Run the package
After adding your settings, run the package with

```
flutter pub run flutter_native_splash:create
```

When the package finishes running your splash screen is ready.

## Notes
* If splash screen was not updated properly on iOS or if you experience a white screen before splash screen, run `flutter clean` and recompile your app. (issue [#9](https://github.com/henriquearthur/flutter_native_splash/issues/9))
* This package modifies `launch_background.xml`, and `styles.xml` files on Android and `LaunchScreen.storyboard`, `Info.plist` and `AppDelegate` on iOS. If you modified this files manually this plugin may not work properly, please [open an issue](https://github.com/henriquearthur/flutter_native_splash/issues/new) if you find any bugs.

## Recommendations
* If you want to use a Material Icon as your splash image, download an icon in [(material.io/resources/icons)](https://material.io/resources/icons/) as **PNG** for **Android**. I recommend using the biggest icon in `drawable-xxxhdpi` folder which was just downloaded for better results.
* Material Colors are available in [material.io/resources/color](https://material.io/resources/color/#!/)

## How it works
### Android
* Your splash image will be resized to `mdpi`, `hdpi`, `xhdpi`, `xxhdpi` and `xxxhdpi` drawables.
* An `<item>` tag containing a `<bitmap>` for your splash image drawable will be added in `launch_background.xml`
* Background color will be added in `colors.xml` and referenced in `launch_background.xml`.
* Code for full screen mode toggle will be added in `styles.xml`.
* Dark mode variants are placed in `drawable-night`, `values-night`, etc. resource folders.

### iOS
* Your splash image will be resized to `@3x` and `@2x` images.
* Color and image properties will be inserted in `LaunchScreen.storyboard`.
* The background color is implemented by using a single pixel png file and stretching it to fit the screen.
* Code for hidden status bar toggle will be added in `Info.plist` and `AppDelegate`.

## Acknowledgments

This package was originally created by [Henrique Arthur](https://github.com/henriquearthur) and it is currently maintained by [Jon Hanson](https://github.com/jonbhanson).  It is heavily inspired by [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) created by [Mark O'Sullivan](https://github.com/MarkOSullivan94) and [Franz Silva](https://github.com/franzsilva).