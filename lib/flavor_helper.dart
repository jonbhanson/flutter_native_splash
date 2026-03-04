part of 'cli_commands.dart';

class _FlavorHelper {
  _FlavorHelper(this._flavor) {
    if (_flavor != null) {
      _androidResFolder = 'android/app/src/$_flavor/res/';
      _iOSFlavorName = _flavor!.capitalize();
    } else {
      _androidResFolder = 'android/app/src/main/res/';
      _iOSFlavorName = '';
    }
  }

  // Android related path values
  final String? _flavor;
  late String _androidResFolder;

  String? get flavor {
    return _flavor;
  }

  String get androidResFolder {
    return _androidResFolder;
  }

  String get androidDrawableFolder {
    return '${_androidResFolder}drawable/';
  }

  String get androidNightDrawableFolder {
    return '${_androidResFolder}drawable-night/';
  }

  String get androidLaunchBackgroundFile {
    return '${androidDrawableFolder}launch_background.xml';
  }

  String get androidLaunchDarkBackgroundFile {
    return '${androidNightDrawableFolder}launch_background.xml';
  }

  String get androidStylesFile {
    return '${_androidResFolder}values/styles.xml';
  }

  String get androidNightStylesFile {
    return '${_androidResFolder}values-night/styles.xml';
  }

  String get androidV31StylesFile {
    return '${_androidResFolder}values-v31/styles.xml';
  }

  String get androidV31StylesNightFile {
    return '${_androidResFolder}values-night-v31/styles.xml';
  }

  String get androidV21DrawableFolder {
    return '${_androidResFolder}drawable-v21/';
  }

  String get androidV21LaunchBackgroundFile {
    return '${androidV21DrawableFolder}launch_background.xml';
  }

  String get androidNightV21DrawableFolder {
    return '${_androidResFolder}drawable-night-v21/';
  }

  String get androidV21LaunchDarkBackgroundFile {
    return '${androidNightV21DrawableFolder}launch_background.xml';
  }

  String? getAndroidDrawableFolder(int minSdk) {
    return minSdk < 21 ? androidDrawableFolder : null;
  }

  String? getAndroidNightDrawableFolder(int minSdk) {
    return minSdk < 21 ? androidNightDrawableFolder : null;
  }

  String? getAndroidLaunchBackgroundFile(int minSdk) {
    return minSdk < 21 ? androidLaunchBackgroundFile : null;
  }

  String? getAndroidLaunchDarkBackgroundFile(int minSdk) {
    return minSdk < 21 ? androidLaunchDarkBackgroundFile : null;
  }

  String? getAndroidStylesFile(int minSdk) {
    return minSdk < 31 ? androidStylesFile : null;
  }

  String? getAndroidNightStylesFile(int minSdk) {
    return minSdk < 31 ? androidNightStylesFile : null;
  }

  String? getAndroidV31StylesFile(int minSdk) {
    return minSdk < 31 ? androidV31StylesFile : androidStylesFile;
  }

  String? getAndroidV31NightStylesFile(int minSdk) {
    return minSdk < 31 ? androidV31StylesNightFile : androidNightStylesFile;
  }

  String? getAndroidV21DrawableFolder(int minSdk) {
    return minSdk < 21 ? androidV21DrawableFolder : androidDrawableFolder;
  }

  String? getAndroidV21LaunchBackgroundFile(int minSdk) {
    return minSdk < 21
        ? androidV21LaunchBackgroundFile
        : androidLaunchBackgroundFile;
  }

  String? getAndroidNightV21DrawableFolder(int minSdk) {
    return minSdk < 21
        ? androidNightV21DrawableFolder
        : androidNightDrawableFolder;
  }

  String? getAndroidV21LaunchDarkBackgroundFile(int minSdk) {
    return minSdk < 21
        ? androidV21LaunchDarkBackgroundFile
        : androidLaunchDarkBackgroundFile;
  }

  String get androidManifestFile {
    return 'android/app/src/main/AndroidManifest.xml';
  }

  // iOS related values
  late String? _iOSFlavorName;

  String? get iOSFlavorName {
    return _iOSFlavorName;
  }

  String get iOSAssetsLaunchImageFolder {
    return 'ios/Runner/Assets.xcassets/LaunchImage$_iOSFlavorName.imageset/';
  }

  String get iOSAssetsBrandingImageFolder {
    return 'ios/Runner/Assets.xcassets/BrandingImage$_iOSFlavorName.imageset/';
  }

  String get iOSLaunchScreenStoryboardFile {
    return 'ios/Runner/Base.lproj/$iOSLaunchScreenStoryboardName.storyboard';
  }

  String get iOSLaunchScreenStoryboardName {
    return 'LaunchScreen$_iOSFlavorName';
  }

  String get iOSInfoPlistFile {
    return 'ios/Runner/Info.plist';
  }

  String get iOSAssetsLaunchImageBackgroundFolder {
    return 'ios/Runner/Assets.xcassets/LaunchBackground$_iOSFlavorName.imageset/';
  }

  String get iOSLaunchScreenStoryBoardContent {
    return _iOSLaunchScreenStoryboardContent.replaceAll(
      '[LAUNCH_IMAGE_PLACEHOLDER]',
      iOSLaunchImageName,
    );
  }

  String get iOSLaunchImageName {
    if (_iOSFlavorName == null) {
      return 'LaunchImage';
    } else {
      return 'LaunchImage$_iOSFlavorName';
    }
  }

  String get iOSBrandingImageName {
    if (_iOSFlavorName == null) {
      return 'BrandingImage';
    } else {
      return 'BrandingImage$_iOSFlavorName';
    }
  }

  String get iOSBrandingSubView {
    return _iOSBrandingSubview.replaceAll(
      '[BRANDING_IMAGE_PLACEHOLDER]',
      iOSBrandingImageName,
    );
  }

  String get iOSLaunchBackgroundName {
    if (_iOSFlavorName == null) {
      return 'LaunchBackground';
    } else {
      return 'LaunchBackground$_iOSFlavorName';
    }
  }

  String get iOSLaunchBackgroundSubView {
    return _iOSLaunchBackgroundSubview.replaceAll(
      '[LAUNCH_BACKGROUND_PLACEHOLDER]',
      iOSLaunchBackgroundName,
    );
  }
}

extension _StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
