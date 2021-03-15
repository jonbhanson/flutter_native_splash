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
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

part 'android.dart';
part 'constants.dart';
part 'exceptions.dart';
part 'ios.dart';
part 'templates.dart';
part 'web.dart';

/// Function that will be called on supported platforms to create the splash screens.
Future<void> tryCreateSplash() async {
  var config = await _getConfig();
  await tryCreateSplashByConfig(config);
}

/// Function that will be called on supported platforms to remove the splash screens.
Future<void> tryRemoveSplash() async {
  print('Restoring Flutter\'s default white native splash screen...');
  await tryCreateSplashByConfig({'color': '#ffffff'});
}

/// Function that will be called on supported platforms to create the splash screen based on a config argument.
Future<void> tryCreateSplashByConfig(Map<String, dynamic> config) async {
  String image = config['image'] ?? '';
  String darkImage = config['image_dark'] ?? '';
  var color = _parseColor(config['color']);
  var darkColor = _parseColor(config['color_dark']);
  String backgroundImage = config['background_image'] ?? '';
  String darkBackgroundImage = config['background_image_dark'] ?? '';
  var plistFiles = config['info_plist_files'];
  var gravity = (config['fill'] ?? false) ? 'fill' : 'center';
  if (config['android_gravity'] != null) gravity = config['android_gravity'];
  bool fullscreen = config['fullscreen'] ?? false;
  String iosContentMode = config['ios_content_mode'] ?? 'center';
  final webImageMode = (config['web_image_mode'] ?? 'center');

  if (!config.containsKey('android') || config['android']) {
    await _createAndroidSplash(
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
    await _createiOSSplash(
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
    await _createWebSplash(
        imagePath: image,
        darkImagePath: darkImage,
        backgroundImage: backgroundImage,
        darkBackgroundImage: darkBackgroundImage,
        color: color,
        darkColor: darkColor,
        imageMode: webImageMode);
  }
}

String _parseColor(var color) {
  if (color is int) color = color.toString().padLeft(6, '0');

  if (color is String) {
    color = color.replaceAll('#', '').replaceAll(' ', '');
    if (color.length == 6) return color;
  }
  if (color == null) return '';

  throw Exception('Invalid color value');
}

/// Get config from `pubspec.yaml` or `flutter_native_splash.yaml`
Map<String, dynamic> _getConfig() {
  // if `flutter_native_splash.yaml` exists use it as config file, otherwise use `pubspec.yaml`
  var filePath = (FileSystemEntity.typeSync('flutter_native_splash.yaml') !=
          FileSystemEntityType.notFound)
      ? 'flutter_native_splash.yaml'
      : 'pubspec.yaml';

  final file = File(filePath);
  final yamlString = file.readAsStringSync();
  final Map yamlMap = loadYaml(yamlString);

  if (!(yamlMap['flutter_native_splash'] is Map)) {
    stderr.writeln(_NoConfigFoundException(
        'Your `$filePath` file does not contain a `flutter_native_splash` section.'));
    exit(1);
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

  if (config.containsKey('color') && config.containsKey('background_image')) {
    stderr.writeln(_InvalidConfigException(
        'Your `flutter_native_splash` section cannot not contain both a `color` and `background_image`.'));
    exit(1);
  }

  if (!config.containsKey('color') && !config.containsKey('background_image')) {
    stderr.writeln(_InvalidConfigException(
        'Your `flutter_native_splash` section does not contain a `color` or `background_image`.'));
    exit(1);
  }

  if (config.containsKey('color_dark') &&
      config.containsKey('background_image_dark')) {
    stderr.writeln(_InvalidConfigException(
        'Your `flutter_native_splash` section cannot not contain both a `color_dark` and `background_image_dark`.'));
    exit(1);
  }

  if (config.containsKey('image_dark') &&
      !config.containsKey('color_dark') &&
      !config.containsKey('background_image_dark')) {
    stderr.writeln(_InvalidConfigException(
        'Your `flutter_native_splash` section contains `image_dark` but does not contain a `color_dark` or a `background_image_dark`.'));
    exit(1);
  }

  return config;
}
