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
part 'ios.dart';
part 'templates.dart';
part 'web.dart';

/// Create splash screens for Android and iOS
void createSplash({String? path}) {
  var config = getConfig(configFile: path);
  _checkConfig(config);
  createSplashByConfig(config);
}

/// Create splash screens for Android and iOS based on a config argument
void createSplashByConfig(Map<String, dynamic> config) {
  var image = _checkImageExists(config: config, parameter: 'image');
  var darkImage = _checkImageExists(config: config, parameter: 'image_dark');
  var brandingImage = _checkImageExists(config: config, parameter: 'branding');
  var brandingDarkImage =
      _checkImageExists(config: config, parameter: 'branding_dark');
  var color = parseColor(config['color']);
  var darkColor = parseColor(config['color_dark']);
  var backgroundImage =
      _checkImageExists(config: config, parameter: 'background_image');
  var darkBackgroundImage =
      _checkImageExists(config: config, parameter: 'background_image_dark');
  var plistFiles = config['info_plist_files'];
  var gravity = (config['fill'] ?? false) ? 'fill' : 'center';
  if (config['android_gravity'] != null) gravity = config['android_gravity'];

  var brandingGravity = config['branding_mode'] ?? 'bottom';

  bool fullscreen = config['fullscreen'] ?? false;
  String iosContentMode = config['ios_content_mode'] ?? 'center';
  final webImageMode = (config['web_image_mode'] ?? 'center');

  if (!config.containsKey('android') || config['android']) {
    if (Directory('android').existsSync()) {
      _createAndroidSplash(
        imagePath: image,
        darkImagePath: darkImage,
        brandingImagePath: brandingImage,
        brandingDarkImagePath: brandingDarkImage,
        backgroundImage: backgroundImage,
        darkBackgroundImage: darkBackgroundImage,
        color: color,
        darkColor: darkColor,
        gravity: gravity,
        brandingGravity: brandingGravity,
        fullscreen: fullscreen,
      );
    } else {
      print('Android folder not found, skipping Android splash update...');
    }
  }

  if (!config.containsKey('ios') || config['ios']) {
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

  if (!config.containsKey('web') || config['web']) {
    if (Directory('web').existsSync()) {
      _createWebSplash(
          imagePath: image,
          darkImagePath: darkImage,
          backgroundImage: backgroundImage,
          darkBackgroundImage: darkBackgroundImage,
          color: color,
          darkColor: darkColor,
          imageMode: webImageMode);
    } else {
      print('Web folder not found, skipping web splash update...');
    }
  }

  const String _greet = '''

Native splash complete. 👍
Now go finish building something awesome! 💪 You rock! 🤘🤩
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
void removeSplash({String? path}) {
  print('Restoring Flutter\'s default native splash screen...');
  var config = getConfig(configFile: path);

  var removeConfig = <String, dynamic>{
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
  createSplashByConfig(removeConfig);
}

String? _checkImageExists(
    {required Map<String, dynamic> config, required String parameter}) {
  String image = config[parameter] ?? '';
  if (image.isNotEmpty && !File(image).existsSync()) {
    print('The file "$image" set as the parameter "$parameter" was not found.');
    exit(1);
  }

  if (image.isNotEmpty && p.extension(image).toLowerCase() != '.png') {
    print('Unsupported file format: ' +
        image +
        '  Your image must be a PNG file.');
    exit(1);
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
  } else if (File('flutter_native_splash.yaml').existsSync()) {
    filePath = 'flutter_native_splash.yaml';
  } else {
    filePath = 'pubspec.yaml';
  }

  final Map yamlMap = loadYaml(File(filePath).readAsStringSync());

  if (yamlMap['flutter_native_splash'] is! Map) {
    throw Exception('Your `$filePath` file does not contain a '
        '`flutter_native_splash` section.');
  }

  // yamlMap has the type YamlMap, which has several unwanted side effects
  final config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry
      in yamlMap['flutter_native_splash'].entries) {
    if (entry.value is YamlList) {
      var list = <String>[];
      for (var value in (entry.value as YamlList)) {
        if (value is String) {
          list.add(value);
        }
      }
      config[entry.key] = list;
    } else {
      config[entry.key] = entry.value;
    }
  }
  return config;
}

void _checkConfig(Map<String, dynamic> config) {
  if (config.containsKey('color') && config.containsKey('background_image')) {
    print('Your `flutter_native_splash` section cannot not contain both a '
        '`color` and `background_image`.');
    exit(1);
  }

  if (!config.containsKey('color') && !config.containsKey('background_image')) {
    print('Your `flutter_native_splash` section does not contain a `color` or '
        '`background_image`.');
    exit(1);
  }

  if (config.containsKey('color_dark') &&
      config.containsKey('background_image_dark')) {
    print('Your `flutter_native_splash` section cannot not contain both a '
        '`color_dark` and `background_image_dark`.');
    exit(1);
  }

  if (config.containsKey('image_dark') &&
      !config.containsKey('color_dark') &&
      !config.containsKey('background_image_dark')) {
    print('Your `flutter_native_splash` section contains `image_dark` but '
        'does not contain a `color_dark` or a `background_image_dark`.');
    exit(1);
  }
}

@visibleForTesting
String? parseColor(var color) {
  if (color is int) color = color.toString().padLeft(6, '0');

  if (color is String) {
    color = color.replaceAll('#', '').replaceAll(' ', '');
    if (color.length == 6) return color;
  }
  if (color == null) return null;

  throw Exception('Invalid color value');
}
