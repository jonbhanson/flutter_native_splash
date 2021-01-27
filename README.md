# flutter_native_splash
[![pub package](https://img.shields.io/pub/v/flutter_native_splash)](https://pub.dev/packages/flutter_native_splash)
[![Build Status](https://img.shields.io/travis/jonbhanson/flutter_native_splash)](https://travis-ci.org/jonbhanson/flutter_native_splash)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](https://makeapullrequest.com)

Automatically generates native code for adding splash screens in Android and iOS. Customize with specific platform, background color and splash image.

<p>
  <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo.gif" width="250" height="443"  />
</p>

## Usage
First, add `flutter_native_splash` as a dev dependency in your pubspec.yaml file. You should add the package to `dev_dependencies` because you don't need this plugin in your APK.

```yaml
dev_dependencies:
  flutter_native_splash: ^0.2.9
```

Don't forget to `flutter pub get`.

### 1. Setting the splash screen
Customized the following settings and add to your project's `pubspec.yaml` file or place in a new file in your root project folder named `flutter_native_splash.yaml`.

```yaml
flutter_native_splash:
  # color is the only required parameter.  It sets the background color of your splash screen.
  color: "#42a5f5"
  
  # Optional parameters are listed below.  To enable a parameter, uncomment the line by removing 
  # the leading # character.

  # The image parameter allows you to specifiy an image used in the splash screen.  It must be a 
  # png file.  
  #image: assets/splash.png

  # The color_dark and image_dark are parameters that set the color and image when the device is 
  # in dark mode.  If they are not specified, the app will use the color and image above.
  # If the image_dark parameter is specified, color_dark must be specified.
  #color_dark: "#042a49"
  #image_dark: assets/splash-invert.png

  # The android and ios parameters can be used to disable generating a splash screen on a given 
  # platform.
  #android: false
  #ios: false

  # The position of the splash image can be set with android_gravity and ios_content_mode 
  # parameters.  Both default to center.
  #
  # android_gravity can be one of the following Android Gravity (see 
  # https://developer.android.com/reference/android/view/Gravity): bottom, center, 
  # center_horizontal, center_vertical, clip_horizontal, clip_vertical, end, fill, fill_horizontal,
  # fill_vertical, left, right, start, or top.
  #android_gravity: center
  #
  # ios_content_mode can be one of the following iOS UIView.ContentMode (see 
  # https://developer.apple.com/documentation/uikit/uiview/contentmode): scaleToFill, 
  # scaleAspectFit, scaleAspectFill, center, top, bottom, left, right, topLeft, topRight, 
  # bottomLeft, or bottomRight.
  #ios_content_mode: center

  # To hide the notification bar on Android, use the android_fullscreen parameter.  Defaults to 
  # false.
  #android_fullscreen: true
  
  # If you have changed the name(s) of your info.plist file(s), you can specify the filename(s) 
  # with the info_plist_files parameter.  Remove only the # characters in the three lines below,
  # do not remove any spaces:
  #info_plist_files:
  #  - 'ios/Runner/Info-Debug.plist'
  #  - 'ios/Runner/Info-Release.plist'
```

### 2. Run the package
After adding your settings, run the package with

```
flutter pub run flutter_native_splash:create
```

When the package finishes running your splash screen is ready.

## Notes
* If splash screen was not updated properly on iOS or if you experience a white screen before splash screen, run `flutter clean` and recompile your app. If that does not solve the problem, delete your app from the device, power down the device, power up device, install and launch app as per [this stackoverflow thread](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update).

* This package modifies `launch_background.xml`, and `styles.xml` files on Android and `LaunchScreen.storyboard`, `Info.plist` and `AppDelegate` on iOS. If you modified this files manually this plugin may not work properly, please [open an issue](https://github.com/jonbhanson/flutter_native_splash/issues/new) if you find any bugs.

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