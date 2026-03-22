import 'dart:io';

import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('parseColor', () {
    test('parses string values correctly', () {
      expect(parseColor('#ffffff'), 'ffffff');
      expect(parseColor(' FAFAFA '), 'FAFAFA');
      expect(parseColor('121212'), '121212');
      expect(parseColor('#000000'), '000000');
      expect(parseColor('F9E524'), 'F9E524');
    });

    test('returns null for null input', () {
      expect(parseColor(null), null);
    });

    test('throws for invalid color strings', () {
      expect(() => parseColor('badcolor'), throwsException);
      expect(() => parseColor('#12345'), throwsException);
      expect(() => parseColor('1234567'), throwsException);
      expect(() => parseColor(''), throwsException);
    });

    test('handles integer values from YAML parsing', () {
      // YAML parses unquoted numeric values like 000000 as int 0
      expect(parseColor(0), '000000');
      // YAML parses 123456 as int
      expect(parseColor(123456), '123456');
    });
  });

  group('config file from args', () {
    final testDir =
        p.join('.dart_tool', 'flutter_native_splash', 'test', 'config_file');

    void setCurrentDirectory(String path) {
      final pathValue = p.join(testDir, path);
      Directory(pathValue).createSync(recursive: true);
      Directory.current = pathValue;
    }

    test('default', () {
      setCurrentDirectory('default');
      File('flutter_native_splash.yaml').writeAsStringSync(
        '''
flutter_native_splash:
  color: "#00ff00"
''',
      );
      final Map<String, dynamic> config = getConfig(
        configFile: 'flutter_native_splash.yaml',
        flavor: null,
      );
      File('flutter_native_splash.yaml').deleteSync();
      expect(config, isNotNull);
      expect(config['color'], '#00ff00');
    });
    test('default_use_pubspec', () {
      setCurrentDirectory('pubspec_only');
      File('pubspec.yaml').writeAsStringSync(
        '''
flutter_native_splash:
  color: "#00ff00"
''',
      );
      final Map<String, dynamic> config = getConfig(
        configFile: null,
        flavor: null,
      );
      File('pubspec.yaml').deleteSync();
      expect(config, isNotNull);
      expect(config['color'], '#00ff00');

      // fails if config file is missing
      expect(() => getConfig(configFile: null, flavor: null), throwsException);
    });
  });
}
