class FlavorHelper {
  FlavorHelper(this._flavor) {
    if (_flavor == null) {
      _androidResFolder = 'android/app/src/main/res/';
    } else {
      _androidResFolder = 'android/app/src/$_flavor/res/';
    }
  }

  // Android-related constants
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
}
