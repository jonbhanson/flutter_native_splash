library flutter_native_splash;

import 'dart:io';

import 'package:flutter_native_splash/android.dart' as android;
import 'package:flutter_native_splash/exceptions.dart';
import 'package:flutter_native_splash/ios.dart' as ios;
import 'package:yaml/yaml.dart';

/// Create splash screen for Android and iOS
void createSplash() async {
  Map<String, dynamic> config = await _getConfig();
  await createSplashByConfig(config);
}

Future<void> createSplashByConfig(Map<String, dynamic> config) async {
  String image = config['image'] ?? '';
  String color = config['color'].toString();
  bool fill = config['fill'] ?? false;
  bool androidDisableFullscreen = config['android_disable_fullscreen'] ?? false;

  if (!config.containsKey("android") || config['android']) {
    await android.createSplash(image, color, fill, androidDisableFullscreen);
  }

  if (!config.containsKey("ios") || config['ios']) {
    await ios.createSplash(image, color, fill);
  }
}

/// Get config from `pubspec.yaml` or `flutter_native_splash.yaml`
Map<String, dynamic> _getConfig() {
  // if `flutter_native_splash.yaml` exists use it as config file, otherwise use `pubspec.yaml`
  String filePath = (FileSystemEntity.typeSync("flutter_native_splash.yaml") !=
          FileSystemEntityType.notFound)
      ? "flutter_native_splash.yaml"
      : "pubspec.yaml";

  final File file = File(filePath);
  final String yamlString = file.readAsStringSync();
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap == null || !(yamlMap['flutter_native_splash'] is Map)) {
    stderr.writeln(NoConfigFoundException(
        "Your `$filePath` file does not contain a `flutter_native_splash` section."));
    exit(1);
  }

  // yamlMap has the type YamlMap, which has several unwanted sideeffects
  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry
      in yamlMap['flutter_native_splash'].entries) {
    config[entry.key] = entry.value;
  }

  if (!config.containsKey('color')) {
    stderr.writeln(InvalidConfigException(
        "Your `flutter_native_splash` section does not contain a `color`."));
    exit(1);
  }

  return config;
}
