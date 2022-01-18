
[![pub package](https://img.shields.io/pub/v/flutter_native_splash)](https://pub.dev/packages/flutter_native_splash)
[![Build Status](https://img.shields.io/travis/jonbhanson/flutter_native_splash)](https://travis-ci.org/jonbhanson/flutter_native_splash)

When your app is opened, there is a brief time while the native app loads Flutter.  By default, during this time, the native app displays a white splash screen.  This package automatically generates iOS, Android, and Web-native code for customizing this native splash screen background color and splash image.  Supports dark mode, full screen, and platform-specific options.

<p align='center'>
    <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo.gif" />
    <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo_dark.gif" />
</p>

# Usage

Would you prefer a video tutorial instead?  Check out <a href="https://www.youtube.com/watch?v=8ME8Czqc-Oc">Johannes Milke's tutorial</a>.

First, add `flutter_native_splash` as a dev dependency in your pubspec.yaml file. It belongs in `dev_dependencies` because it is a command line tool.  Please disregard the instructions in the *Installing* tab that gives different instructions.

```yaml
dev_dependencies:
  flutter_native_splash: ^1.3.3
```

Don't forget to `flutter pub get`.

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
  # png file and should be sized for 4x pixel density.
  #image: assets/splash.png

  # This property allows you to specify an image used as branding in the splash screen. It must be
  # a png file. Currently, it is only supported for Android and iOS.
  branding: assets/dart.png

  # Specify your branding image for dark mode.
  #branding_dark: assets/dart_dark.png

  # To position the branding image at the bottom of the screen you can use bottom, bottomRight,
  # and bottomLeft. The default values is bottom if not specified or specified something else.
  #
  # Make sure this content mode value should not be similar to android_gravity value and ios_content_mode
  # value.
  branding_mode: bottom

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

  # To hide the notification bar, use the fullscreen parameter.  Has no effect in web since web
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

To specify the YAML file location just add --path with the command in the terminal:

```
flutter pub run flutter_native_splash:create --path=path/to/my/file.yaml
```

# Android 12 Support

Android 12 has a [new method](https://developer.android.com/about/versions/12/features/splash-screen) of adding splash screens, which consists of a window background, icon, and the icon background.  Currently, this package supports setting the background color and the icon is taken from the launcher icon.

If you [enable Android 12 support](https://developer.android.com/about/versions/12/setup-sdk), the package will add a `styles.xml` in `values-v31` and `values-night-v31` resource folders, which will provide Android 12 support while maintaining the legacy splash screen for previous versions of Android.

NOTE: The splash screen may not appear when you launch the app from Android Studio.  However, it should appear when you launch by clicking on the launch icon in Android.

# Recommendations
## Secondary splash screen:
The native splash screen is displayed while the native app loads the Flutter framework. Once Flutter loads, there are probably still resources that need to be loaded before your app is ready.  For this reason, you should consider implementing a secondary Flutter splash screen or placeholders that display while these resources load.  The [example](https://github.com/jonbhanson/flutter_native_splash/blob/master/example/lib/main.dart) shows an implementation of a secondary splash screen.
  
# FAQs
## I got the error "A splash screen was provided to Flutter, but this is deprecated."

This message is not related to this package but is related to a [change](https://flutter.dev/docs/development/ui/advanced/splash-screen#migrating-from-manifest--activity-defined-custom-splash-screens) in how Flutter handles splash screens in Flutter 2.5.  It is caused by having the following code in your `AndroidManifest.xml`, which was included by default in previous versions of Flutter:

```xml
<meta-data
 android:name="io.flutter.embedding.android.SplashScreenDrawable"
 android:resource="@drawable/launch_background"
 />
```
The solution is to remove the above code.  Note that this will also remove the fade effect between the native splash screen and your app.

## Can I change the duration of the splash screen?
No, it is not possible to change the duration of the splash screen.  The native splash screen is displayed while the native app loads the Flutter framework. Because the resources in your app cannot load while the native splash screen is displayed, the native splash screen must be as fast as possible.  Note that delaying the user experience is a poor design decision.

## Are animations/lottie/GIF images supported?
Not at this time.  However, you may want to consider a secondary splash screen that supports animation.  See the [secondary splash screen](#secondary-splash-screen) recommendation.

## I got the error AAPT: error: style attribute 'android:attr/windowSplashScreenBackground' not found
This attribute is only found in Android 12, so if you are getting this error, it means your project is not fully set up for Android 12.  Did you [update your app's build configuration](https://developer.android.com/about/versions/12/setup-sdk#config)?

## I see a flash of the wrong splash screen on iOS
This is caused by an [iOS splash caching bug](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update), which can be solved by uninstalling your app, powering off your device, power back on, and then try reinstalling.

## I see a white screen between splash screen and app
1. It may be caused by an [iOS splash caching bug](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update), which can be solved by uninstalling your app, powering off your device, power back on, and then try reinstalling.
2. It may be caused by the delay due to initialization in your app.  To test this, make a test where your `main()` returns a `Container(color: Colors.black);`. If the white flash goes away, it will show that your content is not loading fast enough.  You could solve this by creating a [secondary splash screen](https://pub.dev/packages/flutter_native_splash#secondary-splash-screen) or loading a barebones version of your app with placeholders, and then populate the placeholders as content loads.

# Notes
* If the splash screen was not updated correctly on iOS or if you experience a white screen before the splash screen, run `flutter clean` and recompile your app. If that does not solve the problem, delete your app, power down the device, power up the device, install and launch the app as per [this StackOverflow thread](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update).

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
* The background color is implemented by using a single-pixel png file and stretching it to fit the screen.
* Code for hidden status bar toggle will be added in `Info.plist`.

## Web
* A `web/splash` folder will be created for splash screen images and CSS files.
* Your splash image will be resized to `1x`, `2x`, `3x`, and `4x` sizes and placed in `web/splash/img`.
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
