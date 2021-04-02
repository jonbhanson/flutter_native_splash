/// ## If the current platform is supported, load dart.io.
///
/// Creating images necessary for the splash screens requires the io.dart package, which
/// unfortunately does not have support for JS.  Because pub.dev docks pub points for
/// packages not being cross-platform, it is necessary to use
/// [conditional imports](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files)
/// to avoid losing pub points.  This library is included when the package is loaded on
/// a supported platform, loads dart.io and the rest of the package.
library flutter_native_splash_supported_platform;

import 'dart:io';

import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

part 'android.dart';
part 'constants.dart';
part 'ios.dart';
part 'templates.dart';
part 'web.dart';

/// Function that will be called on supported platforms to create the splash screens.
void tryCreateSplash() {
  var config = getConfig();
  checkConfig(config);
  tryCreateSplashByConfig(config);
}

/// Function that will be called on supported platforms to remove the splash screens.
void tryRemoveSplash() {
  print('Restoring Flutter\'s default white native splash screen...');
  var config = getConfig();

  var removeConfig = <String, dynamic>{'color': '#ffffff'};
  if (config.containsKey('android')) {
    removeConfig['android'] = config['android'];
  }
  if (config.containsKey('ios')) {
    removeConfig['ios'] = config['ios'];
  }
  if (config.containsKey('web')) {
    removeConfig['web'] = config['web'];
  }
  tryCreateSplashByConfig(removeConfig);
}

String checkImageExists(
    {required Map<String, dynamic> config, required String parameter}) {
  String image = config[parameter] ?? '';
  if (image.isNotEmpty && !File(image).existsSync()) {
    print('The file "$image" set as the parameter "$parameter" was not found.');
    exit(1);
  }
  return image;
}

/// Function that will be called on supported platforms to create the splash screen based on a config argument.
void tryCreateSplashByConfig(Map<String, dynamic> config) {
  var image = checkImageExists(config: config, parameter: 'image');
  var darkImage = checkImageExists(config: config, parameter: 'image_dark');
  var color = parseColor(config['color']);
  var darkColor = parseColor(config['color_dark']);
  var backgroundImage =
      checkImageExists(config: config, parameter: 'background_image');
  var darkBackgroundImage =
      checkImageExists(config: config, parameter: 'background_image_dark');
  var plistFiles = config['info_plist_files'];
  var gravity = (config['fill'] ?? false) ? 'fill' : 'center';
  if (config['android_gravity'] != null) gravity = config['android_gravity'];
  bool fullscreen = config['fullscreen'] ?? false;
  String iosContentMode = config['ios_content_mode'] ?? 'center';
  final webImageMode = (config['web_image_mode'] ?? 'center');

  if (!config.containsKey('android') || config['android']) {
    _createAndroidSplash(
      imagePath: image,
      darkImagePath: darkImage,
      backgroundImage: backgroundImage,
      darkBackgroundImage: darkBackgroundImage,
      color: color,
      darkColor: darkColor,
      gravity: gravity,
      fullscreen: fullscreen,
    );
  }

  if (!config.containsKey('ios') || config['ios']) {
    _createiOSSplash(
      imagePath: image,
      darkImagePath: darkImage,
      backgroundImage: backgroundImage,
      darkBackgroundImage: darkBackgroundImage,
      color: color,
      darkColor: darkColor,
      plistFiles: plistFiles,
      iosContentMode: iosContentMode,
      fullscreen: fullscreen,
    );
  }

  if (!config.containsKey('web') || config['web']) {
    _createWebSplash(
        imagePath: image,
        darkImagePath: darkImage,
        backgroundImage: backgroundImage,
        darkBackgroundImage: darkBackgroundImage,
        color: color,
        darkColor: darkColor,
        imageMode: webImageMode);
  }

  print('');
  print('Native splash complete. 👍');
  print('Now go finish building something awesome! 💪 You rock! 🤘🤩');
}

@visibleForTesting
String parseColor(var color) {
  if (color is int) color = color.toString().padLeft(6, '0');

  if (color is String) {
    color = color.replaceAll('#', '').replaceAll(' ', '');
    if (color.length == 6) return color;
  }
  if (color == null) return '';

  throw Exception('Invalid color value');
}

/// Get config from `pubspec.yaml` or `flutter_native_splash.yaml`
Map<String, dynamic> getConfig({String? configFile}) {
  // if `flutter_native_splash.yaml` exists use it as config file, otherwise use `pubspec.yaml`
  String filePath;
  if (configFile != null && File(configFile).existsSync()) {
    filePath = configFile;
  } else if (File('flutter_native_splash.yaml').existsSync()) {
    filePath = 'flutter_native_splash.yaml';
  } else {
    filePath = 'pubspec.yaml';
  }

  final Map yamlMap = loadYaml(File(filePath).readAsStringSync());

  if (!(yamlMap['flutter_native_splash'] is Map)) {
    throw Exception('Your `$filePath` file does not contain a '
        '`flutter_native_splash` section.');
  }

  // yamlMap has the type YamlMap, which has several unwanted side effects
  final config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry
      in yamlMap['flutter_native_splash'].entries) {
    if (entry.value is YamlList) {
      var list = <String>[];
      (entry.value as YamlList).forEach((dynamic value) {
        if (value is String) {
          list.add(value);
        }
      });
      config[entry.key] = list;
    } else {
      config[entry.key] = entry.value;
    }
  }
  return config;
}

void checkConfig(Map<String, dynamic> config) {
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
