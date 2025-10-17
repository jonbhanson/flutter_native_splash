When your app is opened, there is a brief time while the native app loads Flutter. By default, during this time, the native app displays a white splash screen. This package automatically generates iOS, Android, and Web-native code for customizing this native splash screen background color and splash image. Supports dark mode, full screen, and platform-specific options.

<p align='center'>
    <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo.gif" />
    <img src="https://raw.githubusercontent.com/jonbhanson/flutter_native_splash/master/splash_demo_dark.gif" />
</p>

# Usage

First, add `flutter_native_splash` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  flutter_native_splash: ^2.4.7
```

Don't forget to `flutter pub get`.

## 1. Setting the splash screen

Customize the following settings and add to your project's `pubspec.yaml` file or place in a new file in your root project folder named `flutter_native_splash.yaml`.

```yaml
flutter_native_splash:
  # This package generates native code to customize Flutter's default white native splash screen
  # with background color and splash image.
  # Steps to make this work:
  # 1. Customize the parameters below.
  # 2. run the following command in the terminal:
  # dart run flutter_native_splash:create
  # or if you place this not in pubspec.yaml and not in flutter_native_splash.yaml:
  # dart run flutter_native_splash:create -p ../your-filepath.yaml
  # 3. voila, done!

  # NOTES:
  # - in case you got some trouble, cleaning up flutter project might help:
  # flutter clean ; flutter pub get
  # - To restore Flutter's default white splash screen, run the following command in the terminal:
  # dart run flutter_native_splash:remove
  # or if you place this not in pubspec.yaml and not in flutter_native_splash.yaml:
  # dart run flutter_native_splash:remove -p ../your-filepath.yaml

  # IMPORTANT NOTE: These parameter do not affect the configuration of Android 12 and later, which
  # handle splash screens differently that prior versions of Android.  Android 12 and later must be
  # configured specifically in the android_12 section below, at the very end.

  #======================================================================
  
  # uncomment this if you want to disable this package for specific platform:
  # android: false
  # ios: false
  # web: false
  
  #======================================================================

  #! FOR ALL PLATFORM, except Android 12+:

  # general color for all platform (except android 12+):
  # see there only 2 lines in all parameters that marked as [required], so others
  # remain optional. NOTE that if you specify the [required] color, then you cant 
  # use the [required] background_image in the next section. the reverse is true.
  # select one, they cant work together.
  color: "#42a5f5"  ##====================================[REQUIRED]==========
  #color_dark: "#042a49"
  # platform-specific color. will override general color if active:
  #color_android: "#42a5f5"
  #color_dark_android: "#042a49"
  #color_ios: "#42a5f5"
  #color_dark_ios: "#042a49"
  #color_web: "#42a5f5"
  #color_dark_web: "#042a49"

  # general background_image for all platform (except android 12+)
  # if you specify this [required] background_image, then you should comment the 
  # [required] color in previous section. select one, they cant work together.
  #background_image:      "assets/background.png" #========[REQUIRED]============
  #background_image_dark: "assets/dark-background.png"
  # platform-specific background_image. will override general background_image if active:
  #background_image_android:      "assets/background-android.png"
  #background_image_dark_android: "assets/dark-background-android.png"
  #background_image_ios:          "assets/background-ios.png"
  #background_image_dark_ios:     "assets/dark-background-ios.png"
  #background_image_web:          "assets/background-web.png"
  #background_image_dark_web:     "assets/dark-background-web.png"

  # general image for all platform (except android 12+):
  # allows you to specify an image used in the splash screen. It must be a
  # png file and should be sized for 4x pixel density.
  image:                assets/splash.png
  #image_dark:          assets/splash-invert.png
  # platform-specific image. will override general image if active:
  #image_android:       assets/splash-android.png
  #image_dark_android:  assets/splash-invert-android.png
  #image_ios:           assets/splash-ios.png
  #image_dark_ios:      assets/splash-invert-ios.png
  #image_web:           assets/splash-web.gif
  #image_dark_web:      assets/splash-invert-web.gif  

  # image alignment (default center if not specified, or speccified something else):
  #android_gravity: center       # bottom, center, center_horizontal, center_vertical, 
  # clip_horizontal, clip_vertical, end, fill, fill_horizontal, fill_vertical, left, right, start, top. could also be a combination like `android_gravity: fill|clip_vertical`
  # This will fill the width while maintaining the image's vertical aspect ratio.
  # visit https://developer.android.com/reference/android/view/Gravity
  #ios_content_mode: center      # scaleToFill, scaleAspectFit, scaleAspectFill, 
  # center, top, bottom, left, right, topLeft, topRight, bottomLeft, or bottomRight.
  # visit https://developer.apple.com/documentation/uikit/uiview/contentmode
  #web_image_mode: center        # center, contain, stretch, cover

  # general branding for all platform (except android 12+):
  # allows you to specify an image used as branding in the splash screen. should be png.
  #branding:      assets/dart.png
  #branding_dark: assets/dart_dark.png
  # platform-specific branding. will override general branding if active:
  #branding_android:      assets/brand-android.png
  #branding_dark_android: assets/dart_dark-android.png
  #branding_ios:          assets/brand-ios.png
  #branding_dark_ios:     assets/dart_dark-ios.png
  #branding_web:          assets/brand-web.gif
  #branding_dark_web:     assets/dart_dark-web.gif

  # branding position:
  # you can use bottom, bottomRight, and bottomLeft. The default values is 
  # bottom if not specified or specified something else.
  #branding_mode: bottom                # default bottom
  #branding_bottom_padding: 24          # default 0
  #branding_bottom_padding_android: 24  # default 0
  #branding_bottom_padding_ios: 24      # default 0
  # branding bottom padding web is not available yet.

  # The screen orientation can be set in Android with the android_screen_orientation parameter.
  # Valid parameters can be found here:
  # https://developer.android.com/guide/topics/manifest/activity-element#screen
  #android_screen_orientation: sensorLandscape

  # hide notif bar on android. ios already hides it by default. 
  # Has no effect in web since web has no notification bar.
  fullscreen: true                # default false
  # if you dont want to hide notif bar, for android just set this to false,
  # but for ios, add this to your flutter main():
  # WidgetsFlutterBinding.ensureInitialized(); 
  # SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top], );
    
  #! extra note for IOS:
  # If you have changed the name(s) of your info.plist file(s), you can specify the filename(s)
  # with the info_plist_files parameter.  Remove only the # characters in the three lines below,
  # do not remove any spaces:
  #info_plist_files:
  #  - 'ios/Runner/Info-Debug.plist'
  #  - 'ios/Runner/Info-Release.plist'

  #========================================================================

  # what we did above won't affect Android 12 and newer at all. they have different
  # handling concept. visit https://developer.android.com/guide/topics/ui/splash-screen
  
  #! ANDROID 12+ configuration:
  android_12:
    # background color
    color: "#42a5f5"
    # color_dark: "#042a49"

    # center-logo
    # If this parameter is not specified, the app's launcher icon will be used instead. 
    # Please note that the splash screen will be clipped to a circle on the center of the screen. 
    # with background: 960×960 px (fit within circle 640px in diameter)    
    # without background: 1152×1152 px (fit within circle 768px in diameter)
    # ensure that the most important design elements of your image are placed within a circular area 
    image: assets/images/logo/blank.png    
    # image_dark: assets/images/logo/logo-splash2.png  

    # center-logo background color
    icon_background_color: "#111111"
    # icon_background_color_dark: "#eeeeee"

    # branding:
    # The branding image dimensions must be 800x320 px.
    #branding:      assets/dart.png      
    #branding_dark: assets/dart_dark.png
```

## 2. Run the package

After adding your settings to `pubspec.yaml`, run the following command in the terminal:

```
dart run flutter_native_splash:create
```

When the package finishes running, your splash screen is ready.

(Optionally), If you added your config to a separate YAML file instead of `pubspec.yaml`, just add --path with the command in the terminal:

```bash
dart run flutter_native_splash:create --path=path/to/my/file.yaml
```

| Command                | Description                                                                                                                                    |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| -h, --[no-]help        | Show help                                                                                                                                      |
| -p, --path             | Path to the flutter project, if the project is not in it's default location.                                                                   |
| -f, --flavor           | Flavor to create the splash for. The flavor must match the pattern flutter_native_splash-*.yaml (where * is the flavor name).                  |
| -F, --flavors          | Comma separated list of flavors to create the splash screens for. Match the pattern flutter_native_splash-*.yaml (where * is the flavor name). |
| -A, --[no-]all-flavors | Create the splash screens for all flavors that match the pattern flutter_native_splash-*.yaml (where * is the flavor name).                    |

> Note: Only one flavor option is allowed.

## 3. Set up app initialization (optional)

By default, the splash screen will be removed when Flutter has drawn the first frame. If you would like the splash screen to remain while your app initializes, you can use the `preserve()` and `remove()` methods together. Pass the `preserve()` method the value returned from `WidgetsFlutterBinding.ensureInitialized()` to keep the splash on screen. Later, when your app has initialized, make a call to `remove()` to remove the splash screen.

```dart
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

// whenever your initialization is completed, remove the splash screen:
    FlutterNativeSplash.remove();

```

NOTE: If you do not need to use the `preserve()` and `remove()` methods, you can place the `flutter_native_splash` dependency in the `dev_dependencies` section of `pubspec.yaml`.

## 4. Support the package (optional)

If you find this package useful, you can support it for free by giving it a thumbs up at the top of this page. Here's another option to support the package:

<p align='center'><a href="https://www.buymeacoffee.com/jonhanson"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=jonhanson&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a></p>

# Android 12 and Later

Android 12 and later has a [different method](https://developer.android.com/about/versions/12/features/splash-screen) of adding splash screens, which consists of a window background, icon, and the icon background. Note that a background image is not supported.

<img src="https://developer.android.com/static/images/guide/topics/ui/splash-screen/splash-screen-composition.png"/>

Be aware of the following considerations regarding these elements:

1. `image` parameter. By default, the launcher icon is used:

   - App icon without an icon background, as shown on the left: This should be 1152×1152 pixels, and fit within a circle 768 pixels in diameter.
   - App icon with an icon background, as shown on the right: This should be 960×960 pixels, and fit within a circle 640 pixels in diameter.

2. `icon_background_color` is optional, and is useful if you need more contrast between the icon and the window background.

3. One-third of the foreground is masked.

4. `color` the window background consists of a single opaque color.

5. `branding` parameter. The branding image dimensions must be 800x320 px.

**_PLEASE NOTE:_** The splash screen may not appear when you launch the app from Android Studio on API 31. However, it should appear when you launch by clicking on the launch icon in Android. This seems to be resolved in API 32+.

**_PLEASE NOTE:_** There are a number of reports that non-Google launchers do not display the launch image correctly. If the launch image does not display correctly, please try the Google launcher to confirm that this package is working.

**_PLEASE NOTE:_** The splash screen does not appear when you launch the app from a notification. Apparently this is the intended behavior on Android 12: [core-splashscreen Icon not shown when cold launched from notification](https://issuetracker.google.com/issues/199776339?pli=1).

# Flavor Support

If you have a project setup that contains multiple flavors or environments, and you created more than one flavor this would be a feature for you.

Instead of maintaining multiple files and copy/pasting images, you can now, using this tool, create different splash screens for different environments.

## Pre-requirements

In order to use this feature, and generate the desired splash images for your app, a couple of changes are required.

If you want to generate just one flavor and one file you would use either options as described in Step 1. But in order to setup the flavors, you will then be required to move all your setup values to the `flutter_native_splash.yaml` file, but with a prefix.

Let's assume for the rest of the setup that you have 3 different flavors, `Production`, `Acceptance`, `Development`.

First thing you will need to do is to create a different setup file for all 3 flavors with a suffix like so:

```bash
flutter_native_splash-production.yaml
flutter_native_splash-acceptance.yaml
flutter_native_splash-development.yaml
```

You would setup those 3 files the same way as you would the one, but with different assets depending on which environment you would be generating. For example:

```yaml
# flutter_native_splash-development.yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/logo-development.png
  branding: assets/branding-development.png
  color_dark: "#121212"
  image_dark: assets/logo-development.png
  branding_dark: assets/branding-development.png

  android_12:
    image: assets/logo-development.png
    icon_background_color: "#ffffff"
    image_dark: assets/logo-development.png
    icon_background_color_dark: "#121212"

  web: false

# flutter_native_splash-acceptance.yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/logo-acceptance.png
  branding: assets/branding-acceptance.png
  branding_bottom_padding: 24
  color_dark: "#121212"
  image_dark: assets/logo-acceptance.png
  branding_dark: assets/branding-acceptance.png

  android_12:
    image: assets/logo-acceptance.png
    icon_background_color: "#ffffff"
    image_dark: assets/logo-acceptance.png
    icon_background_color_dark: "#121212"

  web: false

# flutter_native_splash-production.yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/logo-production.png
  branding: assets/branding-production.png
  branding_bottom_padding: 24
  color_dark: "#121212"
  image_dark: assets/logo-production.png
  branding_dark: assets/branding-production.png

  android_12:
    image: assets/logo-production.png
    icon_background_color: "#ffffff"
    image_dark: assets/logo-production.png
    icon_background_color_dark: "#121212"

  web: false
```

> Note: these are just example values. You should substitute them with real values.

## One by one

If you'd like to generate only a single flavor (maybe you are
testing something out), you can use only the single command like this:

```bash
# If you have a flavor called production you would do this:
dart run flutter_native_splash:create --flavor production

# For a flavor with a name staging you would provide it's name like so:
dart run flutter_native_splash:create --flavor acceptance

# And if you have a local version for devs you could do that:
dart run flutter_native_splash:create --flavor development
```

## More than one

You also have the ability to specify all the flavors in one command
as shown bellow:

```bash
dart run flutter_native_splash:create --flavors development,staging,production
```

> Note: the available flavors need to be comma separated for this option to work.

## All flavors

And if you have many different flavors available in your project, and wish to generate the splash screen for all of them, you can use this command (starting from 2.4.4):

```bash
dart run flutter_native_splash:create --all-flavors
# OR you can use the shorthand option
dart run flutter_native_splash:create -A
```

This will take all files from the root of the project, scan through them and match for the pattern `flutter_native_splash-*.yaml` where the value at the place of the star will be used as the flavor name and will be consumed to generate the files.

### Android setup

You're done! No, really, Android doesn't need any additional setup.

Note: If it didn't work, please make sure that your flavors are named the same as your config files, otherwise the setup will not work.

### iOS setup

iOS is a bit tricky, so hang tight, it might look scary but most of the steps are just a single click, explained as much as possible to lower the possibility of mistakes.

When you run the new command, you will need to open xCode and follow the steps bellow:

Assumption

- In order for this setup to work, you would already have 3 different `schemes` setup; production, acceptance and development.

Preparation

- Open the iOS Flutter project in Xcode (open the Runner.xcworkspace)
- Find the newly created Storyboard files at the same location where the original is `{project root}/ios/Runner/Base.lproj`
- Select all of them and drag and drop into Xcode, directly to the left hand side where the current LaunchScreen.storyboard is located already
- After you drop your files there Xcode will ask you to link them, make sure you select 'Copy if needed'
- This part is done, you have linked the newly created storyboards in your project.

xCode

Xcode still doesn't know how to use them, so we need to specify for all the current flavors (schemes) which file to use and to use that value inside the Info.plist file.

- Open the iOS Flutter project in Xcode (open the Runner.xcworkspace)
- Click the Runner project in the top left corner (usually the first item in the list)
- In the middle part of the screen, on the left side, select the Runner target
- On the top part of the screen select Build Settings
- Make sure that 'All' and 'Combined' are selected
- Next to 'Combine' you have a '+' button, press it and select 'Add User-Defined Setting'
- Once you do that Xcode will create a new variable for you to name. Suggestion is to name it `LAUNCH_SCREEN_STORYBOARD`
- Once you do that, you will have the option to define a specific name for each flavor (scheme) that you have defined in the project. **Make sure that you input the exact name of the LaunchScreen.storyboard that was created by this tool**
  - Example: If you have a flavor Development, there is a Storyboard created name LaunchScreenDevelopment.storyboard, please add that name (without the storyboard part) to the variable value next to the flavor value
- After you finish with that, you need to update Info.plist file to link the newly created variable so that it's used correctly
- Open the Info.plist file
- Find the entry called 'Launch screen interface file base name'
- The default value is 'LaunchScreen', change that to the variable name that you create previously. If you follow these steps exactly, it would be LAUNCH_SCREEN_STORYBOARD, so input this `$(LAUNCH_SCREEN_STORYBOARD)`
- And your done!

Congrats you finished your setup for multiple flavors,

# FAQs

## I got the error 'module flutter_native_splash' not found.

You may need to run the `pod install` command in your app's `ios` folder.

## I got the error "A splash screen was provided to Flutter, but this is deprecated."

This message is not related to this package but is related to a [change](https://flutter.dev/docs/development/ui/advanced/splash-screen#migrating-from-manifest--activity-defined-custom-splash-screens) in how Flutter handles splash screens in Flutter 2.5. It is caused by having the following code in your `android/app/src/main/AndroidManifest.xml`, which was included by default in previous versions of Flutter:

```xml
<meta-data
 android:name="io.flutter.embedding.android.SplashScreenDrawable"
 android:resource="@drawable/launch_background"
 />
```

The solution is to remove the above code. Note that this will also remove the fade effect between the native splash screen and your app.

## Are animations/lottie/GIF images supported?

GIFs are now supported on web. Lotties are not yet supported. PRs are always welcome!

## I got the error AAPT: error: style attribute 'android:attr/windowSplashScreenBackground' not found

This attribute was added in Android 12, so if you are getting this error, it means your project is not fully set up for Android 12+. Did you [update your app's build configuration](https://developer.android.com/about/versions/12/setup-sdk#config)?

## I see a flash of the wrong splash screen on iOS

This is caused by an [iOS splash caching bug](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update), which can be solved by uninstalling your app, powering off your device, power back on, and then try reinstalling.

## I see a white screen between splash screen and app

1. It may be caused by an [iOS splash caching bug](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update), which can be solved by uninstalling your app, powering off your device, power back on, and then try reinstalling.
2. It may be caused by the delay due to initialization in your app. To solve this, use the `preserve` and `remove` calls to keep the splash on screen while your app initializes.

## Can I base light/dark mode on app settings?

No. This package creates a splash screen that is displayed before Flutter is loaded. Because of this, when the splash screen loads, internal app settings are not available to the splash screen. Unfortunately, this means that it is impossible to control light/dark settings of the splash from app settings.

# Notes

- If the splash screen was not updated correctly on iOS or if you experience a white screen before the splash screen, run `flutter clean` and recompile your app. If that does not solve the problem, delete your app, power down the device, power up the device, install and launch the app as per [this StackOverflow thread](https://stackoverflow.com/questions/33002829/ios-keeping-old-launch-screen-and-app-icon-after-update).

- This package modifies `launch_background.xml` and `styles.xml` files on Android, `LaunchScreen.storyboard` and `Info.plist` on iOS, and `index.html` on Web. If you have modified these files manually, this plugin may not work properly. Please [open an issue](https://github.com//jonbhanson/flutter_native_splash/issues/new?template=bug_report.md) if you find any bugs.

# How it works

## Android

- Your splash image will be resized to `mdpi`, `hdpi`, `xhdpi`, `xxhdpi` and `xxxhdpi` drawables.
- An `<item>` tag containing a `<bitmap>` for your splash image drawable will be added in `launch_background.xml`
- Background color will be added in `colors.xml` and referenced in `launch_background.xml`.
- Code for full screen mode toggle will be added in `styles.xml`.
- Dark mode variants are placed in `drawable-night`, `values-night`, etc. resource folders.

## iOS

- Your splash image will be resized to `@3x` and `@2x` images.
- Color and image properties will be inserted in `LaunchScreen.storyboard`.
- The background color is implemented by using a single-pixel png file and stretching it to fit the screen.
- Code for hidden status bar toggle will be added in `Info.plist`.

## Web

- A `web/splash` folder will be created for splash screen images and CSS files.
- Your splash image will be resized to `1x`, `2x`, `3x`, and `4x` sizes and placed in `web/splash/img`.
- The splash style sheet will be added to the app's `web/index.html`, as well as the HTML for the splash pictures.

# Acknowledgments

This package was originally created by [Henrique Arthur](https://github.com/henriquearthur) and is now maintained by [Jon Hanson](https://github.com/jonbhanson).

# Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com//jonbhanson/flutter_native_splash/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com//jonbhanson/flutter_native_splash/issues/new?template=feature_request.md). Pull request are also welcome.
