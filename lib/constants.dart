part of flutter_native_splash;

// Android-related constants
const String _androidResFolder = 'android/app/src/main/res/';
const String _androidDrawableFolder = _androidResFolder + 'drawable/';
const String _androidNightDrawableFolder =
    _androidResFolder + 'drawable-night/';
const String _androidLaunchBackgroundFile =
    _androidDrawableFolder + 'launch_background.xml';
const String _androidLaunchDarkBackgroundFile =
    _androidNightDrawableFolder + 'launch_background.xml';
const String _androidStylesFile = _androidResFolder + 'values/styles.xml';
const String _androidNightStylesFile =
    _androidResFolder + 'values-night/styles.xml';
const String _androidV21DrawableFolder = _androidResFolder + 'drawable-v21/';
const String _androidV21LaunchBackgroundFile =
    _androidV21DrawableFolder + 'launch_background.xml';
const String _androidNightV21DrawableFolder =
    _androidResFolder + 'drawable-night-v21/';
const String _androidV21LaunchDarkBackgroundFile =
    _androidNightV21DrawableFolder + 'launch_background.xml';

// iOS-related constants
const String _iOSAssetsLaunchImageFolder =
    'ios/Runner/Assets.xcassets/LaunchImage.imageset/';
const String _iOSLaunchScreenStoryboardFile =
    'ios/Runner/Base.lproj/LaunchScreen.storyboard';
const String _iOSInfoPlistFile = 'ios/Runner/Info.plist';
const String _iOSAssetsLaunchImageBackgroundFolder =
    'ios/Runner/Assets.xcassets/LaunchBackground.imageset/';

// Web-related constants
const String _webFolder = 'web/';
const String _webSplashFolder = _webFolder + 'splash/';
const String _webSplashImagesFolder = _webSplashFolder + 'img/';
const String _webIndex = _webFolder + 'index.html';
const String _webRelativeStyleFile = 'splash/style.css';
