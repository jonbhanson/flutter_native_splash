/// ## Flutter Native Splash
///
/// This is the main entry point for the Flutter Native Splash package.
library flutter_native_splash_cli;

import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

part 'android.dart';
part 'constants.dart';
part 'flavor_helper.dart';
part 'ios.dart';
part 'templates.dart';
part 'web.dart';

late _FlavorHelper _flavorHelper;

/// Create splash screens for Android and iOS
void createSplash({String? path, String? flavor}) {
  if (flavor != null) {
    print(
      '''
╔════════════════════════════════════════════════════════════════════════════╗
║                              Flavor detected!                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Setting up the $flavor flavor.
╚════════════════════════════════════════════════════════════════════════════╝
''',
    );
  }

  // It is important that the flavor setup occurs as soon as possible.
  // So before we generate anything, we need to setup the flavor (even if it's the default one).
  _flavorHelper = _FlavorHelper(flavor);

  final config = getConfig(configFile: path);
  _checkConfig(config);
  createSplashByConfig(config);
}

/// Create splash screens for Android and iOS based on a config argument
void createSplashByConfig(Map<String, dynamic> config) {
  // Preparing all the data for later usage
  final String? image = _checkImageExists(config: config, parameter: 'image');
  final String? darkImage =
      _checkImageExists(config: config, parameter: 'image_dark');
  final String? brandingImage =
      _checkImageExists(config: config, parameter: 'branding');
  final String? brandingDarkImage =
      _checkImageExists(config: config, parameter: 'branding_dark');
  final String? color = parseColor(config['color']);
  final String? darkColor = parseColor(config['color_dark']);
  final String? backgroundImage =
      _checkImageExists(config: config, parameter: 'background_image');
  final String? darkBackgroundImage =
      _checkImageExists(config: config, parameter: 'background_image_dark');

  final plistFiles = config['info_plist_files'] as List<String>?;
  String gravity = (config['fill'] as bool? ?? false) ? 'fill' : 'center';
  if (config['android_gravity'] != null) {
    gravity = config['android_gravity'] as String;
  }
  final String? androidScreenOrientation =
      config['android_screen_orientation'] as String?;
  final brandingGravity = config['branding_mode'] as String? ?? 'bottom';
  final bool fullscreen = config['fullscreen'] as bool? ?? false;
  final String iosContentMode =
      config['ios_content_mode'] as String? ?? 'center';
  final webImageMode = config['web_image_mode'] as String? ?? 'center';
  String? android12Image;
  String? android12DarkImage;
  String? android12IconBackgroundColor;
  String? darkAndroid12IconBackgroundColor;
  String? android12Color;
  String? android12DarkColor;

  if (config['android_12'] != null) {
    final android12Config = config['android_12'] as Map<String, dynamic>;
    android12Image =
        _checkImageExists(config: android12Config, parameter: 'image');
    android12DarkImage =
        _checkImageExists(config: android12Config, parameter: 'image_dark');
    android12IconBackgroundColor =
        parseColor(android12Config['icon_background_color']);
    darkAndroid12IconBackgroundColor =
        parseColor(android12Config['icon_background_color_dark']);
    android12Color = parseColor(android12Config['color']) ?? color;
    android12DarkColor = parseColor(android12Config['dark_color']) ?? darkColor;
  }

  if (!config.containsKey('android') || config['android'] as bool) {
    if (Directory('android').existsSync()) {
      _createAndroidSplash(
        imagePath: image,
        darkImagePath: darkImage,
        brandingImagePath: brandingImage,
        brandingDarkImagePath: brandingDarkImage,
        android12ImagePath: android12Image,
        android12DarkImagePath: android12DarkImage,
        android12IconBackgroundColor: android12IconBackgroundColor,
        darkAndroid12IconBackgroundColor: darkAndroid12IconBackgroundColor,
        backgroundImage: backgroundImage,
        darkBackgroundImage: darkBackgroundImage,
        color: android12Color ?? color,
        darkColor: android12DarkColor ?? darkColor,
        gravity: gravity,
        brandingGravity: brandingGravity,
        fullscreen: fullscreen,
        android12DarkBackgroundColor: android12DarkColor,
        android12BackgroundColor: android12Color,
        screenOrientation: androidScreenOrientation,
      );
    } else {
      print('Android folder not found, skipping Android splash update...');
    }
  }

  if (!config.containsKey('ios') || config['ios'] as bool) {
    if (Directory('ios').existsSync()) {
      _createiOSSplash(
        imagePath: image,
        darkImagePath: darkImage,
        backgroundImage: backgroundImage,
        darkBackgroundImage: darkBackgroundImage,
        brandingImagePath: brandingImage,
        brandingDarkImagePath: brandingDarkImage,
        color: color,
        darkColor: darkColor,
        plistFiles: plistFiles,
        iosContentMode: iosContentMode,
        iosBrandingContentMode: brandingGravity,
        fullscreen: fullscreen,
      );
    } else {
      print('iOS folder not found, skipping iOS splash update...');
    }
  }

  if (!config.containsKey('web') || config['web'] as bool) {
    if (Directory('web').existsSync()) {
      _createWebSplash(
        imagePath: image,
        darkImagePath: darkImage,
        backgroundImage: backgroundImage,
        darkBackgroundImage: darkBackgroundImage,
        color: color,
        darkColor: darkColor,
        imageMode: webImageMode,
      );
    } else {
      print('Web folder not found, skipping web splash update...');
    }
  }

  const String _greet = '''

✅ Native splash complete.
Now go finish building something awesome! 💪 You rock! 🤘🤩
Like the package? Please give it a 👍 here: https://pub.dev/packages/flutter_native_splash
''';

  const String _whatsNew = '''
╔════════════════════════════════════════════════════════════════════════════╗
║                                 WHAT IS NEW:                               ║
╠════════════════════════════════════════════════════════════════════════════╣
║ You can now keep the splash screen up while your app initializes!          ║
║ No need for a secondary splash screen anymore. Just use the remove()       ║
║ method to remove the splash screen after your initialization is complete.  ║
║ Check the docs for more info.                                              ║
╚════════════════════════════════════════════════════════════════════════════╝
''';
  print(_whatsNew + _greet);
}

/// Remove any splash screen by setting the default white splash
void removeSplash({String? path, String? flavor}) {
  _flavorHelper = _FlavorHelper(flavor);
  print("Restoring Flutter's default native splash screen...");
  final config = getConfig(configFile: path);

  final removeConfig = <String, dynamic>{
    'color': '#ffffff',
    'color_dark': '#000000'
  };

  if (config.containsKey('android')) {
    removeConfig['android'] = config['android'];
  }

  if (config.containsKey('ios')) {
    removeConfig['ios'] = config['ios'];
  }

  if (config.containsKey('web')) {
    removeConfig['web'] = config['web'];
  }

  /// Checks if the image that was specified in the config file does exist.
  /// If not the developer will receive an error message and the process will exit.
  if (config.containsKey('info_plist_files')) {
    removeConfig['info_plist_files'] = config['info_plist_files'];
  }
  createSplashByConfig(removeConfig);
}

String? _checkImageExists({
  required Map<String, dynamic> config,
  required String parameter,
}) {
  final String? image = config[parameter]?.toString();
  if (image != null) {
    if (image.isNotEmpty && !File(image).existsSync()) {
      print(
        'The file "$image" set as the parameter "$parameter" was not found.',
      );
      exit(1);
    }

    if (p.extension(image).toLowerCase() != '.png') {
      print(
        'Unsupported file format: $image  Your image must be a PNG file.',
      );
      exit(1);
    }
  }

  return image == '' ? null : image;
}

/// Get config from `pubspec.yaml` or `flutter_native_splash.yaml`
Map<String, dynamic> getConfig({String? configFile}) {
  // if `flutter_native_splash.yaml` exists use it as config file, otherwise use `pubspec.yaml`
  String filePath;
  if (configFile != null) {
    if (File(configFile).existsSync()) {
      filePath = configFile;
    } else {
      print('The config file `$configFile` was not found.');
      exit(1);
    }
  } else if (_flavorHelper.flavor != null) {
    filePath = 'flutter_native_splash-${_flavorHelper.flavor}.yaml';
  } else if (File('flutter_native_splash.yaml').existsSync()) {
    filePath = 'flutter_native_splash.yaml';
  } else {
    filePath = 'pubspec.yaml';
  }

  final Map yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;

  if (yamlMap['flutter_native_splash'] is! Map) {
    throw Exception(
      'Your `$filePath` file does not contain a '
      '`flutter_native_splash` section.',
    );
  }

  // yamlMap has the type YamlMap, which has several unwanted side effects
  return _yamlToMap(yamlMap['flutter_native_splash'] as YamlMap);
}

Map<String, dynamic> _yamlToMap(YamlMap yamlMap) {
  final Map<String, dynamic> map = <String, dynamic>{};
  for (final MapEntry<dynamic, dynamic> entry in yamlMap.entries) {
    if (entry.value is YamlList) {
      final list = <String>[];
      for (final value in entry.value as YamlList) {
        if (value is String) {
          list.add(value);
        }
      }
      map[entry.key as String] = list;
    } else if (entry.value is YamlMap) {
      map[entry.key as String] = _yamlToMap(entry.value as YamlMap);
    } else {
      map[entry.key as String] = entry.value;
    }
  }
  return map;
}

/// Validates if the mix and match of different setup values are not conflicting with each other.
/// If they do, the developer will get a message where the issue is.
void _checkConfig(Map<String, dynamic> config) {
  if (config.containsKey('color') && config.containsKey('background_image')) {
    print(
      'Your `flutter_native_splash` section cannot not contain both a '
      '`color` and `background_image`.',
    );
    exit(1);
  }

  if (!config.containsKey('color') && !config.containsKey('background_image')) {
    print(
      'Your `flutter_native_splash` section does not contain a `color` or '
      '`background_image`.',
    );
    exit(1);
  }

  if (config.containsKey('color_dark') &&
      config.containsKey('background_image_dark')) {
    print(
      'Your `flutter_native_splash` section cannot not contain both a '
      '`color_dark` and `background_image_dark`.',
    );
    exit(1);
  }

  if (config.containsKey('image_dark') &&
      !config.containsKey('color_dark') &&
      !config.containsKey('background_image_dark')) {
    print(
      'Your `flutter_native_splash` section contains `image_dark` but '
      'does not contain a `color_dark` or a `background_image_dark`.',
    );
    exit(1);
  }

  if (config.containsKey('branding_dark') && !config.containsKey('branding')) {
    print(
      'Your `flutter_native_splash` section contains `branding_dark` but '
      'does not contain a `branding`.',
    );
    exit(1);
  }
}

@visibleForTesting
String? parseColor(dynamic color) {
  dynamic colorValue = color;
  if (colorValue is int) colorValue = colorValue.toString().padLeft(6, '0');

  if (colorValue is String) {
    colorValue = colorValue.replaceAll('#', '').replaceAll(' ', '');
    if (colorValue.length == 6) return colorValue;
  }
  if (colorValue == null) return null;

  throw Exception('Invalid color value');
}
