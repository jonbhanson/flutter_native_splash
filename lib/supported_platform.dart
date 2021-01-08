import 'dart:io';

import 'package:flutter_native_splash/android.dart' as android;
import 'package:flutter_native_splash/exceptions.dart';
import 'package:flutter_native_splash/ios.dart' as ios;
import 'package:yaml/yaml.dart';

Future<void> tryCreateSplash() async {
  var config = await _getConfig();
  await tryCreateSplashByConfig(config);
}

Future<void> tryCreateSplashByConfig(Map<String, dynamic> config) async {
  String image = config['image'] ?? '';
  String darkImage = config['image_dark'] ?? '';
  var color = config['color'].toString();
  var darkColor = config['color_dark']?.toString() ?? '';
  bool fill = config['fill'] ?? false;
  bool androidDisableFullscreen = config['android_disable_fullscreen'] ?? false;

  if (!config.containsKey('android') || config['android']) {
    await android.createSplash(
        image, darkImage, color, darkColor, fill, androidDisableFullscreen);
  }

  if (!config.containsKey('ios') || config['ios']) {
    await ios.createSplash(image, darkImage, color, darkColor);
  }
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

  if (yamlMap == null || !(yamlMap['flutter_native_splash'] is Map)) {
    stderr.writeln(NoConfigFoundException(
        'Your `$filePath` file does not contain a `flutter_native_splash` section.'));
    exit(1);
  }

  // yamlMap has the type YamlMap, which has several unwanted sideeffects
  final config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry
      in yamlMap['flutter_native_splash'].entries) {
    config[entry.key] = entry.value;
  }

  if (!config.containsKey('color')) {
    stderr.writeln(InvalidConfigException(
        'Your `flutter_native_splash` section does not contain a `color`.'));
    exit(1);
  }

  if (config.containsKey('image_dark') && !config.containsKey('color_dark')) {
    stderr.writeln(InvalidConfigException(
        'Your `flutter_native_splash` section contains `image_dark` but does not contain a `color_dark`.'));
    exit(1);
  }

  return config;
}
