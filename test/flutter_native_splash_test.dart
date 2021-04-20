import 'dart:io';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('Android splash images list is correct size', () {
    expect(androidSplashImages.length, 5);
    expect(androidSplashImagesDark.length, 5);
  });

  test('iOS splash images list is correct size', () {
    expect(iOSSplashImages.length, 3);
    expect(iOSSplashImagesDark.length, 3);
  });

  test('parseColor parses values correctly', () {
    expect(parseColor('#ffffff'), 'ffffff');
    expect(parseColor(' FAFAFA '), 'FAFAFA');
    expect(parseColor('121212'), '121212');
    expect(parseColor(null), '');
    expect(() => parseColor('badcolor'), throwsException);
  });

  group('config file from args', () {
    final testDir =
        join('.dart_tool', 'flutter_native_splash', 'test', 'config_file');

    late String currentDirectory;
    void setCurrentDirectory(String path) {
      path = join(testDir, path);
      Directory(path).createSync(recursive: true);
      Directory.current = path;
    }

    setUp(() {
      currentDirectory = Directory.current.path;
    });
    tearDown(() {
      Directory.current = currentDirectory;
    });
    test('default', () {
      setCurrentDirectory('default');
      File('flutter_native_splash.yaml').writeAsStringSync('''
flutter_native_splash:
  color: "#00ff00"
''');
      final Map<String, dynamic>? config =
          getConfig(configFile: 'flutter_native_splash.yaml');
      File('flutter_native_splash.yaml').deleteSync();
      expect(config, isNotNull);
      expect(config!['color'], '#00ff00');
    });
    test('default_use_pubspec', () {
      setCurrentDirectory('pubspec_only');
      File('pubspec.yaml').writeAsStringSync('''
flutter_native_splash:
  color: "#00ff00"
''');
      final Map<String, dynamic>? config = getConfig();
      File('pubspec.yaml').deleteSync();
      expect(config, isNotNull);
      expect(config!['color'], '#00ff00');

      // fails if config file is missing
      expect(() => getConfig(), throwsException);
    });
  });
}
