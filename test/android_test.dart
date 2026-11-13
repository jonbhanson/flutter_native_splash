import 'dart:io';

import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'package:xml/xml.dart';

const _res = 'android/app/src/main/res';
const _densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

void main() {
  group('android_12 app_theme_styles', () {
    late Directory originalDirectory;
    late Directory project;

    setUp(() {
      originalDirectory = Directory.current;
      project = Directory.systemTemp.createTempSync('flutter_native_splash_');
      Directory.current = project;
      Directory(_res).createSync(recursive: true);
      File('android/app/src/main/AndroidManifest.xml').writeAsStringSync(
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
        '<application><activity android:name=".MainActivity"/></application>'
        '</manifest>',
      );
      // Different sizes, so a copy shows which image it came from.
      File('light.png').writeAsBytesSync(encodePng(Image(width: 8, height: 8)));
      File('dark.png')
          .writeAsBytesSync(encodePng(Image(width: 16, height: 16)));
    });

    tearDown(() {
      Directory.current = originalDirectory;
      project.deleteSync(recursive: true);
    });

    void create(String android12) {
      File('flutter_native_splash.yaml').writeAsStringSync('''
flutter_native_splash:
  color: "#ffffff"
  ios: false
  web: false
  android_12:
$android12
''');
      createSplash(path: 'flutter_native_splash.yaml', flavor: null);
    }

    test('are not added without the option', () {
      create('''
    color: "#f7f8fa"
    color_dark: "#0b0f16"
''');
      expect(_style('values-v31', 'LaunchTheme'), isNotNull);
      expect(_style('values-v31', 'NativeSplashLight'), isNull);
      expect(_style('values-v31', 'NativeSplashDark'), isNull);
    });

    test('use night-free copies when the dark image differs', () async {
      create('''
    color: "#f7f8fa"
    color_dark: "#0b0f16"
    image: light.png
    image_dark: dark.png
    icon_background_color: "#111111"
    app_theme_styles: true
''');
      await _waitForImages([
        for (final d in _densities) ...[
          '$_res/drawable-$d/android12splash.png',
          '$_res/drawable-night-$d/android12splash.png',
          '$_res/drawable-$d/android12splash_light.png',
          '$_res/drawable-$d/android12splash_dark.png',
        ],
      ]);

      final light = _style('values-v31', 'NativeSplashLight')!;
      expect(
        light.getAttribute('parent'),
        '@android:style/Theme.Light.NoTitleBar',
      );
      expect(_items(light), {
        'android:windowSplashScreenBackground': '#f7f8fa',
        'android:windowSplashScreenAnimatedIcon':
            '@drawable/android12splash_light',
        'android:windowSplashScreenIconBackgroundColor': '#111111',
      });
      final dark = _style('values-v31', 'NativeSplashDark')!;
      expect(
        dark.getAttribute('parent'),
        '@android:style/Theme.Black.NoTitleBar',
      );
      expect(_items(dark), {
        'android:windowSplashScreenBackground': '#0b0f16',
        'android:windowSplashScreenAnimatedIcon':
            '@drawable/android12splash_dark',
        'android:windowSplashScreenIconBackgroundColor': '#111111',
      });
      expect(_style('values-night-v31', 'NativeSplashLight'), isNull);
      expect(_style('values-night-v31', 'NativeSplashDark'), isNull);
      expect(
        _items(_style('values-v31', 'LaunchTheme')!),
        containsPair(
          'android:windowSplashScreenAnimatedIcon',
          '@drawable/android12splash',
        ),
      );

      final darkCopy = File('$_res/drawable-xxxhdpi/android12splash_dark.png');
      expect(decodePng(darkCopy.readAsBytesSync())!.width, 16);
      expect(
        Directory(_res).listSync(recursive: true).where(
              (f) =>
                  f.path.contains('night') &&
                  f.path.contains(RegExp('_(light|dark)')),
            ),
        isEmpty,
      );

      removeSplash(path: 'flutter_native_splash.yaml', flavor: null);
      expect(_style('values-v31', 'NativeSplashLight'), isNull);
      expect(_style('values-v31', 'NativeSplashDark'), isNull);
      expect(darkCopy.existsSync(), isFalse);
    });

    test('share the drawable when there is one image', () async {
      create('''
    color: "#f7f8fa"
    color_dark: "#0b0f16"
    image: light.png
    app_theme_styles: true
''');
      await _waitForImages([
        for (final d in _densities) ...[
          '$_res/drawable-$d/android12splash.png',
          '$_res/drawable-night-$d/android12splash.png',
        ],
      ]);

      for (final name in ['NativeSplashLight', 'NativeSplashDark']) {
        expect(
          _items(_style('values-v31', name)!),
          containsPair(
            'android:windowSplashScreenAnimatedIcon',
            '@drawable/android12splash',
          ),
        );
      }
      expect(
        File('$_res/drawable-xxxhdpi/android12splash_light.png').existsSync(),
        isFalse,
      );
    });
  });
}

XmlElement? _style(String values, String name) {
  final file = File('$_res/$values/styles.xml');
  return XmlDocument.parse(file.readAsStringSync())
      .findAllElements('style')
      .where((style) => style.getAttribute('name') == name)
      .firstOrNull;
}

Map<String, String> _items(XmlElement style) => {
      for (final item in style.findElements('item'))
        item.getAttribute('name')!: item.innerText,
    };

/// Android images are written by background isolates. Wait for them, so none
/// is still being written when the test changes the current directory.
Future<void> _waitForImages(List<String> paths) async {
  bool written(String path) {
    final file = File(path);
    return file.existsSync() && decodePng(file.readAsBytesSync()) != null;
  }

  for (var i = 0; i < 200 && !paths.every(written); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect(paths.where((path) => !written(path)), isEmpty);
}
