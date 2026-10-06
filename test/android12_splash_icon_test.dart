import 'dart:io';

import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

void main() {
  late Directory originalDirectory;
  late Directory temporaryDirectory;

  final res = p.join('android', 'app', 'src', 'main', 'res');
  final iconFile = p.join(res, 'drawable-v31', 'android12splash_icon.xml');

  setUp(() {
    originalDirectory = Directory.current;
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'flutter-native-splash-android12-test',
    );
    Directory.current = temporaryDirectory;

    final manifest =
        File(p.join('android', 'app', 'src', 'main', 'AndroidManifest.xml'))
          ..createSync(recursive: true);
    manifest.writeAsStringSync('''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name=".MainActivity"/>
    </application>
</manifest>
''');

    File(p.join('assets', 'logo.png'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(img.encodePng(img.Image(width: 8, height: 8)));
  });

  tearDown(() {
    Directory.current = originalDirectory;
    temporaryDirectory.deleteSync(recursive: true);
  });

  String? splashIcon(String stylesFolder) {
    final styles = XmlDocument.parse(
      File(p.join(res, stylesFolder, 'styles.xml')).readAsStringSync(),
    );
    final launchTheme = styles.findAllElements('style').singleWhere(
          (style) => style.getAttribute('name') == 'LaunchTheme',
        );
    return launchTheme
        .findElements('item')
        .where(
          (item) =>
              item.getAttribute('name') ==
              'android:windowSplashScreenAnimatedIcon',
        )
        .singleOrNull
        ?.innerText;
  }

  test('wraps the Android 12 icon so the system draws it at full size',
      () async {
    File('flutter_native_splash.yaml').writeAsStringSync('''
flutter_native_splash:
  ios: false
  web: false
  color: "#ffffff"
  android_12:
    image: assets/logo.png
''');

    createSplash(path: 'flutter_native_splash.yaml', flavor: null);
    await _waitForAndroid12Bitmaps(res);

    expect(splashIcon('values-v31'), '@drawable/android12splash_icon');
    expect(splashIcon('values-night-v31'), '@drawable/android12splash_icon');

    final animationList =
        XmlDocument.parse(File(iconFile).readAsStringSync()).rootElement;
    expect(animationList.name.local, 'animation-list');
    expect(animationList.getAttribute('android:oneshot'), 'true');
    final frames = animationList.findElements('item').toList();
    expect(frames, hasLength(1));
    expect(
      frames.single.getAttribute('android:drawable'),
      '@drawable/android12splash',
    );
  });

  test('removes the wrapper when no Android 12 image is configured', () async {
    File('flutter_native_splash.yaml').writeAsStringSync('''
flutter_native_splash:
  ios: false
  web: false
  color: "#ffffff"
  android_12:
    image: assets/logo.png
''');
    createSplash(path: 'flutter_native_splash.yaml', flavor: null);
    await _waitForAndroid12Bitmaps(res);
    expect(File(iconFile).existsSync(), isTrue);

    File('flutter_native_splash.yaml').writeAsStringSync('''
flutter_native_splash:
  ios: false
  web: false
  color: "#ffffff"
''');
    createSplash(path: 'flutter_native_splash.yaml', flavor: null);

    expect(File(iconFile).existsSync(), isFalse);
    expect(splashIcon('values-v31'), isNull);
    expect(splashIcon('values-night-v31'), isNull);
  });
}

/// Waits for the light and dark android12splash bitmaps in every density.
///
/// createSplash writes them from isolates that it does not await, so a test
/// must wait before it runs createSplash again or leaves its temporary
/// directory; otherwise a late write lands in the wrong place.
Future<void> _waitForAndroid12Bitmaps(String res) async {
  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];
  final bitmaps = [
    for (final night in ['', '-night'])
      for (final density in densities)
        File(p.join(res, 'drawable$night-$density', 'android12splash.png')),
  ];
  bool decoded(File file) =>
      file.existsSync() && img.decodePng(file.readAsBytesSync()) != null;

  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!bitmaps.every(decoded)) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for the android12splash bitmaps.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
