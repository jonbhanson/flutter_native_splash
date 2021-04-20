
[![pub package](https://img.shields.io/pub/v/flutter_native_splash)](https://pub.dev/packages/flutter_native_splash)
[![Build Status](https://img.shields.io/travis/jonbhanson/flutter_native_splash)](https://travis-ci.org/jonbhanson/flutter_native_splash)

When your app is opened, there is a brief time while the native app loads Flutter.  By default, during this time the native app displays a white splash screen.  This package automatically generates iOS, Android, and Web native code for customizing this native splash screen background color and splash image.  Supports dark mode, full screen, and platform-specific options.

<p align='center'>
    <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo.gif" />
    <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo_dark.gif" />
</p>

# Usage

Would you prefer a video tutorial instead?  Check out <a href="https://www.youtube.com/watch?v=8ME8Czqc-Oc">Johannes Milke's tutorial</a>.

First, add `flutter_native_splash` as a dev dependency in your pubspec.yaml file. It belongs in `dev_dependencies` because it is a command line tool.

```yaml
dev_dependencies:
  flutter_native_splash: ^1.1.8+4
```

Don't forget to `flutter pub get`.

> #### NOTE:
> 
> If you are using Flutter 1.x (no null safety), you must use the <a href="https://pub.dev/packages/flutter_native_splash/versions">0.x version</a> of this package.

## 1. Setting the splash screen
Customized the following settings and add to your project's `pubspec.yaml` file or place in a new file in your root project folder named `flutter_native_splash.yaml`.

```yaml
flutter_native_splash:

  # This package generates native code to customize Flutter's default white native splash screen
  # with background color and splash image.
  # Customize the parameters below, and run the following command in the terminal:
  # flutter pub run flutter_native_splash:create
  # To restore Flutter's default white splash screen, run the following command in the terminal:
  # flutter pub run flutter_native_splash:remove

  # color or background_image is the only required parameter.  Use color to set the background
  # of your splash screen to a solid color.  Use background_image to set the background of your
  # splash screen to a png image.  This is useful for gradients. The image will be stretch to the
  # size of the app. Only one parameter can be used, color and background_image cannot both be set.
  color: "#42a5f5"
  #background_image: "assets/background.png"
  
  # Optional parameters are listed below.  To enable a parameter, uncomment the line by removing 
  # the leading # character.

  # The image parameter allows you to specify an image used in the splash screen.  It must be a 
  # png file.  
  #image: assets/splash.png

  # The color_dark, background_image_dark, and image_dark are parameters that set the background
  # and image when the device is in dark mode. If they are not specified, the app will use the
  # parameters from above. If the image_dark parameter is specified, color_dark or 
  # background_image_dark must be specified.  color_dark and background_image_dark cannot both be
  # set.
  #color_dark: "#042a49"
  #background_image_dark: "assets/dark-background.png"
  #image_dark: assets/splash-invert.png

  # The android, ios and web parameters can be used to disable generating a splash screen on a given 
  # platform.
  #android: false
  #ios: false
  #web: false

  # The position of the splash image can be set with android_gravity, ios_content_mode, and
  # web_image_mode parameters.  All default to center.
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
  #
  # web_image_mode can be one of the following modes: center, contain, stretch, and cover.
  #web_image_mode: center

  # To hide the notification bar, use the fullscreen parameter.  Has no affect in web since web 
  # has no notification bar.  Defaults to false.
  # NOTE: Unlike Android, iOS will not automatically show the notification bar when the app loads.
  #       To show the notification bar, add the following code to your Flutter app:
  #       WidgetsFlutterBinding.ensureInitialized();
  #       SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
  #fullscreen: true
  
  # If you have changed the name(s) of your info.plist file(s), you can specify the filename(s) 
  # with the info_plist_files parameter.  Remove only the # characters in the three lines below,
  # do not remove any spaces:
  #info_plist_files:
  #  - 'ios/Runner/Info-Debug.plist'
  #  - 'ios/Runner/Info-Release.plist'
```

## 2. Run the package
After adding your settings, run the following command in the terminal:

```
flutter pub run flutter_native_splash:create
```

When the package finishes running, your splash screen is ready.

# Recommendations
## Secondary splash screen:
The native splash screen is displayed while the native app loads the Flutter framework. Once Flutter loads, there may still be resources that need to be loaded before your app is ready.  For this reason, you should consider implementing a Flutter splash screen that is displayed while these resources load.  Here is a code example of a secondary Flutter splash screen, or use a package from [pub.dev](https://pub.dev).

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: Splash());
        } else {
          // Loading is done, return the app:
          return MaterialApp(
            home: Scaffold(body: Center(child: Text('App loaded'))),
          );
        }
      },
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.apartment_outlined,
          size: MediaQuery.of(context).size.width * 0.785,
        ),
      ),
    );
  }
}
```



## Material resources:
* If you want to use a Material Icon as your splash image, download an icon in [(material.io/resources/icons)](https://material.io/resources/icons/) as **PNG** for **Android**. I recommend using the biggest icon in `drawable-xxxhdpi` folder which was just downloaded for better results.
  
* Material Colors are available in [material.io/resources/color](https://material.io/resources/color/#!/)
  
# FAQs
## Can I change the duration of the splash screen?
The native splash screen is displayed while the native app loads the Flutter framework. Because the resources in your app cannot load while the native splash screen is displayed, the native splash screen must be as fast as possible.  However, if you want a longer splash screen, see the [secondary splash screen](#secondary-splash-screen) recommendation.

## Are animations/lottie/GIF images supported?
Not at this time.  However, you may want to consider a secondary splash screen that supports animation.  See the [secondary splash screen](#secondary-splash-screen) recommendation.

# Notes
* If splash screen was not updated properly on iOS or if you experience a white screen before splash screen, run `flutter clean` and recompile your app. If that does not solve the problem, delete your app from the device, power down the device, power up device, install and launch app as per [this stackoverflow thread](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update).

* This package modifies `launch_background.xml` and `styles.xml` files on Android, `LaunchScreen.storyboard` and `Info.plist` on iOS, and `index.html` on Web. If you have modified these files manually, this plugin may not work properly. Please [open an issue](https://github.com//jonbhanson/flutter_native_splash/issues/new?template=bug_report.md) if you find any bugs.

# How it works
## Android
* Your splash image will be resized to `mdpi`, `hdpi`, `xhdpi`, `xxhdpi` and `xxxhdpi` drawables.
* An `<item>` tag containing a `<bitmap>` for your splash image drawable will be added in `launch_background.xml`
* Background color will be added in `colors.xml` and referenced in `launch_background.xml`.
* Code for full screen mode toggle will be added in `styles.xml`.
* Dark mode variants are placed in `drawable-night`, `values-night`, etc. resource folders.

## iOS
* Your splash image will be resized to `@3x` and `@2x` images.
* Color and image properties will be inserted in `LaunchScreen.storyboard`.
* The background color is implemented by using a single pixel png file and stretching it to fit the screen.
* Code for hidden status bar toggle will be added in `Info.plist`.

## Web
* A `web/splash` folder will be created for splash screen images and CSS files.
* Your splash image will be resized to `1x`, `2x`, and `3x` sizes and placed in `web/splash/img`.
* The splash style sheet will be added to the app's `web/index.html`, as well as the HTML for the splash pictures.

# Removing

If you would like to restore Flutter's default white splash screen, run the following command in the terminal:

```
flutter pub run flutter_native_splash:remove
```

# Acknowledgments

This package was originally created by [Henrique Arthur](https://github.com/henriquearthur) and it is currently maintained by [Jon Hanson](https://github.com/jonbhanson).

# Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com//jonbhanson/flutter_native_splash/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com//jonbhanson/flutter_native_splash/issues/new?template=feature_request.md). Pull request are also welcome.
