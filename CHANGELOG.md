## [1.1.8+4] - (2021-Apr-20)

* Fixed bug that was preventing copying of dark background.  Fixes [#163](https://github.com/jonbhanson/flutter_native_splash/issues/163).

## [1.1.7+1] - (2021-Apr-02)

* flutter_native_splash:remove adheres to android/ios/web setting.  Fixes [#159](https://github.com/jonbhanson/flutter_native_splash/issues/159).
* Updated readme images.

## [1.1.6+1] - (2021-Mar-29)

* Corrected Android scaling.  Thanks [@chris-efission](https://github.com/chris-efission).
* Updated readme image.

## [1.1.5+1] - (2021-Mar-23)

* Added unit tests.
* Updated dependency.

## [1.1.4+1] - (2021-Mar-18)

* Fixed bug that created duplicate android:windowFullscreen tags in styles.xml. Closes [#147](https://github.com/jonbhanson/flutter_native_splash/issues/147).
* Fixed fullscreen in Android dark mode.
* Print errors instead of throwing exceptions for cleaner output.
* Added message for missing subviews in iOS LaunchScreen.storyboard. Fixes [#146](https://github.com/jonbhanson/flutter_native_splash/issues/146).
* Removed duplicate exceptions for missing image file since that is now checked at package start.

## [1.1.3] - (2021-Mar-18)

* Fixed bug that was giving error on copying background image.  Closes [#144](https://github.com/jonbhanson/flutter_native_splash/issues/144).

## [1.1.2] - (2021-Mar-17)

* Check that image files exist before starting.  Throw an exception if image file not found.

## [1.1.1+1] - (2021-Mar-16)

* Create Styles.css before writing to it.  Closes [#141](https://github.com/jonbhanson/flutter_native_splash/issues/141)
* Make all file calls synchronously to make code cleaner.

## [1.1.0] - (2021-Mar-15)

* Added option for background image.  Closes [#22](https://github.com/jonbhanson/flutter_native_splash/issues/22).

## [1.0.3] - (2021-Mar-05)

* Updated readme.

## [1.0.2] - (2021-Mar-04)

* Added exception for missing/renamed splash image in LaunchScreen.storyboard.

## [1.0.1+1] - (2021-Mar-02)

* Corrected location of `picture` tag in web to ensure that splash disappears.  Thanks [Dawid Dziurla](https://github.com/dawidd6).

## [1.0.0] - (2021-Feb-19)

* Adds null safety.  Closes [#127](https://github.com/jonbhanson/flutter_native_splash/issues/127).

## [0.3.0] - (2021-Feb-10)

* Added support for web.  Closes [#30](https://github.com/jonbhanson/flutter_native_splash/issues/30).
* Updated the example app to include web.

## [0.2.11] - (2021-Feb-09)

* Fixed `remove` command which was leaving splash images in place.

## [0.2.10] - (2021-Feb-08)

* Replaced `android_fullscreen` with `fullscreen` parameter, adding iOS support. closes [#75](https://github.com/jonbhanson/flutter_native_splash/issues/75), closes [#65](https://github.com/jonbhanson/flutter_native_splash/issues/65).
* The package no longer modifies the AppDelegate.  Fixes [#125](https://github.com/jonbhanson/flutter_native_splash/issues/125), fixes [#66](https://github.com/jonbhanson/flutter_native_splash/issues/66).
* Added `remove` command.  Closes [#97](https://github.com/jonbhanson/flutter_native_splash/issues/97), closes [#126](https://github.com/jonbhanson/flutter_native_splash/issues/126).
* Updated docs.

## [0.2.9] - (2021-Jan-27)

* Correct iOS 2x scaling. Closes [#27](https://github.com/jonbhanson/flutter_native_splash/issues/27).
* Fullscreen defaults to false.  Closes [#122](https://github.com/jonbhanson/flutter_native_splash/issues/122).

## [0.2.8] - (2021-Jan-25)

* Allow users to set Android gravity and iOS ContentMode directly. 
* Parse LaunchScreen.storyboard with XML package for more reliability.  
* Updated install instructions.  
* Fixes [#18](https://github.com/jonbhanson/flutter_native_splash/issues/18). Closes [#63](https://github.com/jonbhanson/flutter_native_splash/pull/63).

## [0.2.7] - (2021-Jan-18)

* Added configuration parameter to specify the info.plist location(s). 
* Updated documentation.  
* Fixes [#120](https://github.com/jonbhanson/flutter_native_splash/issues/120), [#42](https://github.com/jonbhanson/flutter_native_splash/issues/42).

## [0.2.6] - (2021-Jan-14)

* Added support for Android -v21 resource folders, which appear in the Flutter beta channel.  
* Parse launch_background.xml with XML package for more reliability.  
* Fixes [#104](https://github.com/jonbhanson/flutter_native_splash/issues/104), [#118](https://github.com/jonbhanson/flutter_native_splash/issues/118).


## [0.2.5] - (2021-Jan-13)

* Handle color parameter that are passed as integers.  Fixes [#103](https://github.com/jonbhanson/flutter_native_splash/issues/103)

## [0.2.4] - (2021-Jan-12)

* Update code that adds fullscreen mode to Android so that it selects the right style (LaunchTheme) in styles.xml.  This should resolve [#39](https://github.com/jonbhanson/flutter_native_splash/issues/39), [#54](https://github.com/jonbhanson/flutter_native_splash/issues/54), [#67](https://github.com/jonbhanson/flutter_native_splash/issues/67), [#92](https://github.com/jonbhanson/flutter_native_splash/issues/92), [#112](https://github.com/jonbhanson/flutter_native_splash/issues/112), and [#117](https://github.com/jonbhanson/flutter_native_splash/issues/117).  
* Removed code that modifies MainActivity as it is not longer needed since Flutter embedding V2 uses two styles in styles.xml so full screen is set independently in the style.

## [0.2.3] - (2021-Jan-11)

* Further modifications to raise [pub points](https://pub.dev/help/scoring): The 
public API's need to have dartdoc comments, so all public declarations that did not
need to be public were changed to private.  Added doc comments for public APIs. 

## [0.2.2] - (2021-Jan-09)

* Corrected color of background PNG for iOS.  ([The channel order of a uint32 encoded color is BGRA.](https://pub.dev/documentation/image/latest/image/Color/fromRgb.html)) ([#115](https://github.com/jonbhanson/flutter_native_splash/issues/115))

## [0.2.1] - (2021-Jan-08)

* Modifications to raise [pub points](https://pub.dev/help/scoring): Adherence to [Pedantic](https://pub.dev/packages/pedantic) code standard, and [conditional imports](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files) to avoid losing points for lack of multiple platform support.

## [0.2.0+1] - (2021-Jan-08)

* Updated version number in README.md (thanks [@M123-dev](https://github.com/M123-dev))

## [0.2.0] - (2021-Jan-07)

* Added dark mode.

## [0.1.9] - 

* (2020-Jan-27) Added createSplashByConfig for external usage
* (2020-Jan-05) Fix run the package command (thanks [@tenhobi](https://github.com/tenhobi))
* (2019-Oct-31) Removing comments from the example (thanks [@lucalves](https://github.com/lucalves))
* (2019-Oct-16) `image` parameter is now optional ([#26](https://github.com/jonbhanson/flutter_native_splash/issues/26))

## [0.1.8+4] - (12th October 2019)

* Fix bug on RegEx preventing `package` tag from being found in `AndroidManifest.xml` ([#25](https://github.com/jonbhanson/flutter_native_splash/issues/25))

## [0.1.8+3] - (4th October 2019)

* Prevent unhandled int exception in `color` argument (thanks [@wemersonrv](https://github.com/wemersonrv) - PR [#23](https://github.com/jonbhanson/flutter_native_splash/pull/23))

## [0.1.8+2] - (16th September 2019)

* Fix code being added multiple times to `MainActivity` ([#19](https://github.com/jonbhanson/flutter_native_splash/issues/19))

## [0.1.8+1] - (16th September 2019)

* Documentation improvements

## [0.1.8] - (16th September 2019)

* Added `fill` property to use full screen images on Android (thanks [@Bwofls2](https://github.com/Bwolfs2) - PR [#8](https://github.com/jonbhanson/flutter_native_splash/pull/8)) 
* Added `android_disable_fullscreen` property to disable opening app in full screen on Android ([#14](https://github.com/jonbhanson/flutter_native_splash/issues/14))
* Status bar color on Android is now generated dynamically by using same principles as Material Design (thanks [@yiss](https://github.com/yiss) - PR [#16](https://github.com/jonbhanson/flutter_native_splash/pull/16))

## [0.1.7+2] - (1th September 2019)

* Fix a bug on `minSdkVersion` reading ([#13](https://github.com/jonbhanson/flutter_native_splash/issues/13))

## [0.1.7+1] - (1th September 2019)

* Check for `minSdkVersion` >= 21 to add code for changing status bar color to transparent ([#12](https://github.com/jonbhanson/flutter_native_splash/issues/12))

## [0.1.7] - (27th August 2019)

* Fix a bug that duplicates entries on `Info.plist` when using multiple `</dict>` on iOS ([#5](https://github.com/jonbhanson/flutter_native_splash/issues/5))
* Fix missing imports on `MainActivity` when not using default class signature ([#7](https://github.com/jonbhanson/flutter_native_splash/issues/7))

## [0.1.6+2] - (27th August 2019)

* Yup, I released a new version because a quote was missing

## [0.1.6+1] - (27th August 2019)

* Updated README.md adding quotes on `color` property
* Add support for colors with `#` prefix

## [0.1.6] - (26th August 2019)

* Fix bug where `MainActivity` file could not be found with custom package names

## [0.1.5] - (26th August 2019)

* Add support for Kotlin
* Add support for Swift
* Add `await` to every step to create splash screen on Android and iOS to prevent async steps causing error

## [0.1.4] - (25th August 2019)

* Fix code style issues pointed by `dartanalzyer`
* Fix typo in README.md

## [0.1.3] - (25th August 2019)

* Update README.md

## [0.1.2] - (25th August 2019)

* Fix Travis CI filename


## [0.1.1] - (25th August 2019)

* Added Travis CI and updates to README.md


## [0.1.0] - (25th August 2019)

* Initial release: generate Android and iOS splash screens with a background color and an image
