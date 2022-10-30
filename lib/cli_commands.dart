/// ## Flutter Native Splash
///
/// This is the main entry point for the Flutter Native Splash package.
library flutter_native_splash_cli;

import 'package:html/parser.dart' as html_parser;
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
void createSplash({
  required String? path,
  required String? flavor,
}) {
  if (flavor != null) {
    print(
      '''
╔════════════════════════════════════════════════════════════════════════════╗
║                              Flavor detected!                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Setting up the $flavor flavor.                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
''',
    );
  }

  final config = getConfig(configFile: path, flavor: flavor);
  createSplashByConfig(config);
}

/// Create splash screens for Android and iOS based on a config argument
void createSplashByConfig(Map<String, dynamic> config) {
  // Preparing all the data for later usage
  final String? image = _checkImageExists(config: config, parameter: 'image');
  final String? imageAndroid =
      _checkImageExists(config: config, parameter: 'image_android');
  final String? imageIos =
      _checkImageExists(config: config, parameter: 'image_ios');
  final String? imageWeb =
      _checkImageExists(config: config, parameter: 'image_web');
  final String? darkImage =
      _checkImageExists(config: config, parameter: 'image_dark');
  final String? darkImageAndroid =
      _checkImageExists(config: config, parameter: 'image_dark_android');
  final String? darkImageIos =
      _checkImageExists(config: config, parameter: 'image_dark_ios');
  final String? darkImageWeb =
      _checkImageExists(config: config, parameter: 'image_dark_web');
  final String? brandingImage =
      _checkImageExists(config: config, parameter: 'branding');
  final String? brandingImageAndroid =
      _checkImageExists(config: config, parameter: 'branding_android');
  final String? brandingImageIos =
      _checkImageExists(config: config, parameter: 'branding_ios');
  final String? brandingImageWeb =
      _checkImageExists(config: config, parameter: 'branding_web');
  final String? brandingDarkImage =
      _checkImageExists(config: config, parameter: 'branding_dark');
  final String? brandingDarkImageAndroid =
      _checkImageExists(config: config, parameter: 'branding_dark_android');
  final String? brandingDarkImageIos =
      _checkImageExists(config: config, parameter: 'branding_dark_ios');
  final String? brandingDarkImageWeb =
      _checkImageExists(config: config, parameter: 'branding_dark_web');
  final String? color = parseColor(config['color']);
  final String? darkColor = parseColor(config['color_dark']);
  final String? backgroundImage =
      _checkImageExists(config: config, parameter: 'background_image');
  final String? backgroundImageAndroid =
      _checkImageExists(config: config, parameter: 'background_android');
  final String? backgroundImageIos =
      _checkImageExists(config: config, parameter: 'background_ios');
  final String? backgroundImageWeb =
      _checkImageExists(config: config, parameter: 'background_web');
  final String? darkBackgroundImage =
      _checkImageExists(config: config, parameter: 'background_image_dark');
  final String? darkBackgroundImageAndroid = _checkImageExists(
    config: config,
    parameter: 'background_image_dark_android',
  );
  final String? darkBackgroundImageIos =
      _checkImageExists(config: config, parameter: 'background_image_dark_ios');
  final String? darkBackgroundImageWeb =
      _checkImageExists(config: config, parameter: 'background_image_dark_web');

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
  String? android12BrandingImage;
  String? android12DarkBrandingImage;

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
    android12DarkColor = parseColor(android12Config['color_dark']) ?? darkColor;
    android12BrandingImage =
        _checkImageExists(config: android12Config, parameter: 'branding');
    android12DarkBrandingImage =
        _checkImageExists(config: android12Config, parameter: 'branding_dark');
  }

  if (!config.containsKey('android') || config['android'] as bool) {
    if (Directory('android').existsSync()) {
      _createAndroidSplash(
        imagePath: imageAndroid ?? image,
        darkImagePath: darkImageAndroid ?? darkImage,
        brandingImagePath: brandingImageAndroid ?? brandingImage,
        brandingDarkImagePath: brandingDarkImageAndroid ?? brandingDarkImage,
        backgroundImage: backgroundImageAndroid ?? backgroundImage,
        darkBackgroundImage: darkBackgroundImageAndroid ?? darkBackgroundImage,
        color: color,
        darkColor: darkColor,
        gravity: gravity,
        brandingGravity: brandingGravity,
        fullscreen: fullscreen,
        screenOrientation: androidScreenOrientation,
        android12ImagePath: android12Image,
        android12DarkImagePath: android12DarkImage ?? android12Image,
        android12BackgroundColor: android12Color,
        android12DarkBackgroundColor: android12DarkColor ?? android12Color,
        android12IconBackgroundColor: android12IconBackgroundColor,
        darkAndroid12IconBackgroundColor:
            darkAndroid12IconBackgroundColor ?? android12IconBackgroundColor,
        android12BrandingImagePath: android12BrandingImage,
        android12DarkBrandingImagePath:
            android12DarkBrandingImage ?? android12BrandingImage,
      );
    } else {
      print('Android folder not found, skipping Android splash update...');
    }
  }

  if (!config.containsKey('ios') || config['ios'] as bool) {
    if (Directory('ios').existsSync()) {
      _createiOSSplash(
        imagePath: imageIos ?? image,
        darkImagePath: darkImageIos ?? darkImage,
        backgroundImage: backgroundImageIos ?? backgroundImage,
        darkBackgroundImage: darkBackgroundImageIos ?? darkBackgroundImage,
        brandingImagePath: brandingImageIos ?? brandingImage,
        brandingDarkImagePath: brandingDarkImageIos ?? brandingDarkImage,
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
        imagePath: imageWeb ?? image,
        darkImagePath: darkImageWeb ?? darkImage,
        backgroundImage: backgroundImageWeb ?? backgroundImage,
        darkBackgroundImage: darkBackgroundImageWeb ?? darkBackgroundImage,
        brandingImagePath: brandingImageWeb ?? brandingImage,
        brandingDarkImagePath: brandingDarkImageWeb ?? brandingDarkImage,
        color: color,
        darkColor: darkColor,
        imageMode: webImageMode,
        brandingMode: brandingGravity,
      );
    } else {
      print('Web folder not found, skipping web splash update...');
    }
  }

  const String greet = '''

✅ Native splash complete.
Now go finish building something awesome! 💪 You rock! 🤘🤩
Like the package? Please give it a 👍 here: https://pub.dev/packages/flutter_native_splash
''';

  const String whatsNew = '''
╔════════════════════════════════════════════════════════════════════════════╗
║                                 WHAT IS NEW:                               ║
╠════════════════════════════════════════════════════════════════════════════╣
║ You can now keep the splash screen up while your app initializes!          ║
║ No need for a secondary splash screen anymore. Just use the remove()       ║
║ method to remove the splash screen after your initialization is complete.  ║
║ Check the docs for more info.                                              ║
╚════════════════════════════════════════════════════════════════════════════╝
''';
  print(whatsNew + greet);
}

/// Remove any splash screen by setting the default white splash
void removeSplash({
  required String? path,
  required String? flavor,
}) {
  print("Restoring Flutter's default native splash screen...");
  final config = getConfig(configFile: path, flavor: flavor);

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
Map<String, dynamic> getConfig({
  required String? configFile,
  required String? flavor,
}) {
  // It is important that the flavor setup occurs as soon as possible.
  // So before we generate anything, we need to setup the flavor (even if it's the default one).
  _flavorHelper = _FlavorHelper(flavor);
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
