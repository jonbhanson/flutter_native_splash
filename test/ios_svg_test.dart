import 'dart:convert';
import 'dart:io';

import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

void main() {
  late Directory originalDirectory;
  late Directory temporaryDirectory;

  setUp(() {
    originalDirectory = Directory.current;
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'flutter-native-splash-ios-svg-test',
    );
    Directory.current = temporaryDirectory;

    final plist = File(p.join('ios', 'Runner', 'Info.plist'));
    plist.createSync(recursive: true);
    plist.writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>UIStatusBarHidden</key>
  <false/>
</dict>
</plist>
''');
  });

  tearDown(() {
    Directory.current = originalDirectory;
    temporaryDirectory.deleteSync(recursive: true);
  });

  test('preserves an iOS splash SVG with a raster dark image', () {
    final assets = Directory('assets')..createSync();
    File(p.join(assets.path, 'splash.svg')).writeAsStringSync(
      '<svg width=".5px" height="+1e2pt" '
      'xmlns="http://www.w3.org/2000/svg"/>',
    );
    File(p.join(assets.path, 'splash-dark.png')).writeAsBytesSync(
      img.encodePng(img.Image(width: 4, height: 4)),
    );
    _writeConfig('''
  image_ios: assets/splash.svg
  image_dark_ios: assets/splash-dark.png
''');

    final launchImages = _launchImagesDirectory()..createSync(recursive: true);
    File(p.join(launchImages.path, 'LaunchImage.png'))
        .writeAsStringSync('stale raster');

    createSplash(path: 'flutter_native_splash.yaml', flavor: null);

    expect(File(p.join(launchImages.path, 'LaunchImage.svg')).existsSync(),
        isTrue);
    expect(
      File(p.join(launchImages.path, 'LaunchImage.png')).existsSync(),
      isFalse,
    );
    final contents = jsonDecode(
      File(p.join(launchImages.path, 'Contents.json')).readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(contents['properties'], {'preserves-vector-representation': true});
    expect(
      (contents['images'] as List<dynamic>)
          .map((entry) => (entry as Map<String, dynamic>)['filename']),
      [
        'LaunchImage.svg',
        'LaunchImageDark.png',
        'LaunchImageDark@2x.png',
        'LaunchImageDark@3x.png',
      ],
    );

    final storyboard = XmlDocument.parse(
      File(p.join('ios', 'Runner', 'Base.lproj', 'LaunchScreen.storyboard'))
          .readAsStringSync(),
    );
    final splash = storyboard.findAllElements('image').firstWhere(
          (element) => element.getAttribute('name') == 'LaunchImage',
        );
    expect(splash.getAttribute('width'), '0.5');
    expect(splash.getAttribute('height'), '100');
  });

  test('validates the SVG before changing generated assets', () {
    final assets = Directory('assets')..createSync();
    File(p.join(assets.path, 'invalid.svg')).writeAsStringSync(
      '<svg width="100%" height="100%" '
      'xmlns="http://www.w3.org/2000/svg"/>',
    );
    _writeConfig('  image_ios: assets/invalid.svg\n');

    final launchImages = _launchImagesDirectory()..createSync(recursive: true);
    final existingImage = File(p.join(launchImages.path, 'LaunchImage.png'))
      ..writeAsStringSync('existing raster');
    final existingContents = File(p.join(launchImages.path, 'Contents.json'))
      ..writeAsStringSync('existing contents');

    expect(
      () => createSplash(path: 'flutter_native_splash.yaml', flavor: null),
      throwsA(
        isA<Exception>().having(
          (exception) => exception.toString(),
          'message',
          contains('must define positive width and height values'),
        ),
      ),
    );
    expect(existingImage.readAsStringSync(), 'existing raster');
    expect(existingContents.readAsStringSync(), 'existing contents');
  });

  test('removes a stale SVG when switching back to a raster image', () {
    final assets = Directory('assets')..createSync();
    File(p.join(assets.path, 'splash.png')).writeAsBytesSync(
      img.encodePng(img.Image(width: 4, height: 4)),
    );
    _writeConfig('  image_ios: assets/splash.png\n');

    final launchImages = _launchImagesDirectory()..createSync(recursive: true);
    File(p.join(launchImages.path, 'LaunchImage.svg'))
        .writeAsStringSync('stale vector');

    createSplash(path: 'flutter_native_splash.yaml', flavor: null);

    expect(
      File(p.join(launchImages.path, 'LaunchImage.svg')).existsSync(),
      isFalse,
    );
  });
}

void _writeConfig(String imageConfiguration) {
  File('flutter_native_splash.yaml').writeAsStringSync('''
flutter_native_splash:
  android: false
  web: false
  color: "#ffffff"
$imageConfiguration''');
}

Directory _launchImagesDirectory() => Directory(
      p.join('ios', 'Runner', 'Assets.xcassets', 'LaunchImage.imageset'),
    );
