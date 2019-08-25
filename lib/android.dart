import 'package:flutter_native_splash/constants.dart';
import 'package:flutter_native_splash/exceptions.dart';
import 'package:flutter_native_splash/xml_templates.dart' as xml_templates;
import 'package:image/image.dart';
import 'dart:io';

// Image template
class AndroidDrawableTemplate {
  AndroidDrawableTemplate({this.size, this.directoryName});

  final String directoryName;
  final int size;
}

final List<AndroidDrawableTemplate> splashImages = <AndroidDrawableTemplate>[
  AndroidDrawableTemplate(directoryName: 'drawable-mdpi', size: 144),
  AndroidDrawableTemplate(directoryName: 'drawable-hdpi', size: 216),
  AndroidDrawableTemplate(directoryName: 'drawable-xhdpi', size: 288),
  AndroidDrawableTemplate(directoryName: 'drawable-xxhdpi', size: 432),
  AndroidDrawableTemplate(directoryName: 'drawable-xxxhdpi', size: 576),
];

/// Create Android splash screen
createSplash(String imagePath, String color) async {
  _applyImage(imagePath);
  await _applyLaunchBackgroundXml();

  // _applyColor will update launch_background.xml which may be created in _applyLaunchBackgroundXml
  // that's why we need to await _applyLaunchBackgroundXml()
  _applyColor(color);
  _applyStylesXml();

  _applyMainActivityUpdate();
}

/// Create splash screen as drawables for multiple screens (dpi)
void _applyImage(String imagePath) {
  print("[Android] Creating splash images");

  final File file = File(imagePath);

  if (!file.existsSync()) {
    throw NoImageFileFoundException("The file $imagePath was not found.");
  }

  final Image image = decodeImage(File(imagePath).readAsBytesSync());

  for (AndroidDrawableTemplate template in splashImages) {
    _saveImage(template, image);
  }
}

/// Saves splash screen image to the project
/// Note: Do not change interpolation unless you end up with better results
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void _saveImage(AndroidDrawableTemplate template, Image image) {
  Image newFile;

  if (image.width >= template.size) {
    newFile = copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.average);
  } else {
    newFile = copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.linear);
  }

  File(androidResFolder + template.directoryName + '/' + 'splash.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

/// Create or update launch_background.xml adding splash image path
Future _applyLaunchBackgroundXml() {
  final File launchBackgroundFile = File(androidLaunchBackgroundFile);

  if (launchBackgroundFile.existsSync()) {
    print("[Android] Updating launch_background.xml with splash image path");
    return _updateLaunchBackgroundFileWithImagePath();
  } else {
    print(
        "[Android] No launch_background.xml file found in your Android project");
    print(
        "[Android] Creating launch_background.xml file and adding it to your Android project");
    return _createLaunchBackgroundFileWithImagePath();
  }
}

/// Updates launch_background.xml adding splash image path
Future _updateLaunchBackgroundFileWithImagePath() async {
  final File launchBackgroundFile = File(androidLaunchBackgroundFile);
  final List<String> lines = await launchBackgroundFile.readAsLines();
  bool foundExisting = false;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (line.contains('android:src="@drawable/splash"')) {
      foundExisting = true;
      break;
    }
  }

  // Add new line if we didn't find an existing value
  if (!foundExisting) {
    lines.insert(lines.length - 1, xml_templates.launchBackgroundItemXml);
  }

  launchBackgroundFile.writeAsString(lines.join('\n'));
}

/// Creates launch_background.xml with splash image path
Future _createLaunchBackgroundFileWithImagePath() async {
  File file = await File(androidLaunchBackgroundFile).create(recursive: true);
  return await file.writeAsString(xml_templates.launchBackgroundXml);
}

/// Create or update colors.xml adding splash screen background color
void _applyColor(color) {
  final File colorsXml = File(androidColorsFile);

  color = "#" + color;

  if (colorsXml.existsSync()) {
    print(
        "[Android] Updating colors.xml with color for splash screen background");
    _updateColorsFileWithColor(colorsXml, color);
  } else {
    print("[Android] No colors.xml file found in your Android project");
    print(
        "[Android] Creating colors.xml file and adding it to your Android project");
    _createColorsFile(color);
  }

  _overwriteLaunchBackgroundWithNewSplashColor(color);
}

/// Updates the colors.xml with the splash screen background color
void _updateColorsFileWithColor(File colorsFile, String color) {
  final List<String> lines = colorsFile.readAsLinesSync();
  bool foundExisting = false;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // Update background color if tag exists
    if (line.contains('name="splash_color"')) {
      foundExisting = true;
      // replace anything between tags which does not contain another tag
      line = line.replaceAll(RegExp(r'>([^><]*)<'), '>$color<');
      lines[x] = line;
      break;
    }
  }

  // Add new line if we didn't find an existing value
  if (!foundExisting) {
    lines.insert(
        lines.length - 1, '\t<color name="splash_color">$color</color>');
  }

  colorsFile.writeAsStringSync(lines.join('\n'));
}

/// Creates a colors.xml file if it was missing from android/app/src/main/res/values/colors.xml
void _createColorsFile(String color) {
  File(androidColorsFile).create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(xml_templates.colorsXml).then((File file) {
      _updateColorsFileWithColor(colorsFile, color);
    });
  });
}

/// Updates the line which specifies the splash screen background color within the AndroidManifest.xml
/// with the new icon name (only if it has changed)
///
/// Note: default color = "splash_color"
Future _overwriteLaunchBackgroundWithNewSplashColor(String color) async {
  final File launchBackgroundFile = File(androidLaunchBackgroundFile);
  final List<String> lines = await launchBackgroundFile.readAsLines();

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];
    if (line.contains('android:drawable')) {
      // Using RegExp replace the value of android:drawable to point to the new image
      // anything but a quote of any length: [^"]*
      // an escaped quote: \\" (escape slash, because it exists regex)
      // quote, no quote / quote with things behind : \"[^"]*
      // repeat as often as wanted with no quote at start: [^"]*(\"[^"]*)*
      // escaping the slash to place in string: [^"]*(\\"[^"]*)*"
      // result: any string which does only include escaped quotes
      line = line.replaceAll(RegExp(r'android:drawable="[^"]*(\\"[^"]*)*"'),
          'android:drawable="@color/splash_color"');
      lines[x] = line;
      // used to stop git showing a diff if the icon name hasn't changed
      lines.add('');
    }
  }
  launchBackgroundFile.writeAsString(lines.join('\n'));
}

/// Create or update styles.xml full screen mode setting
void _applyStylesXml() {
  final File stylesFile = File(androidStylesFile);

  if (stylesFile.existsSync()) {
    print("[Android] Updating styles.xml with full screen mode setting");
    _updateStylesFileWithImagePath();
  } else {
    print("[Android] No styles.xml file found in your Android project");
    print(
        "[Android] Creating styles.xml file and adding it to your Android project");
    _createStylesFileWithImagePath();
  }
}

/// Updates styles.xml adding full screen property
Future _updateStylesFileWithImagePath() async {
  final File stylesFile = File(androidStylesFile);
  final List<String> lines = await stylesFile.readAsLines();
  bool foundExisting = false;
  int endStyleLine;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (line.contains('android:windowFullscreen')) {
      foundExisting = true;
    }

    if (line.contains('</style>')) {
      endStyleLine = x;
    }
  }

  // Add new line if we didn't find an existing value
  if (!foundExisting) {
    lines.insert(endStyleLine, xml_templates.stylesItemXml);
  }

  stylesFile.writeAsString(lines.join('\n'));
}

/// Creates styles.xml with full screen property
void _createStylesFileWithImagePath() {
  File(androidStylesFile).create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(xml_templates.stylesXml);
  });
}

/// Update MainActivity.java adding code to remove full screen mode after app load
Future _applyMainActivityUpdate() async {
  final String mainActivityPath = await _getMainActivityPath();
  final File mainActivityFile = File(mainActivityPath);
  final List<String> lines = await mainActivityFile.readAsLines();

  if (_needToUpdateMainActivity(lines)) {
    _addMainActivitySplashLines(mainActivityFile, lines);
  }
}

Future _getMainActivityPath() async {
  File androidManifest = File(androidManifestFile);
  final List<String> lines = await androidManifest.readAsLines();

  bool foundPath = false;
  String mainActivityPath = 'android/app/src/main/java/';

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (line.contains('package="')) {
      RegExp regExp = RegExp(r'package="([^"]*(\\"[^"]*)*)">');

      var matches = regExp.allMatches(line);
      var match = matches.elementAt(0);

      String package = match.group(1);
      List<String> packageSplitted = package.split('.');

      String path1 = packageSplitted[0];
      String path2 = packageSplitted[1];
      String path3 = packageSplitted[2];

      mainActivityPath += "$path1/$path2/$path3/MainActivity.java";
      foundPath = true;
      break;
    }
  }

  if (!foundPath) {
    throw CantFindMainActivityPath(
        "Not able to determinate MainActivity.java path. Maybe the problem is your package path OR your AndroidManifest.xml 'package' attribute on manifest.");
  }

  return mainActivityPath;
}

/// Check if MainActivity.java needs to be updated with code required for splash screen
bool _needToUpdateMainActivity(List<String> lines) {
  bool foundExisting = false;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // if file contains our variable we're assuming it contains all required code
    if (line.contains('boolean flutter_native_splash = true;')) {
      foundExisting = true;
      break;
    }
  }

  return !foundExisting;
}

/// Add in MainActivity.java the code required for removing full screen mode of splash screen after app loaded
void _addMainActivitySplashLines(File mainActivityFile, List<String> lines) {
  List<String> newLines = [];

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // Before 'public class ...' add the following lines
    if (line.contains('public class MainActivity extends FlutterActivity {')) {
      newLines.add(xml_templates.mainActivityLines1);
    }

    newLines.add(line);

    // After 'super.onCreate ...' add the following lines
    if (line.contains('super.onCreate(savedInstanceState);')) {
      newLines.add(xml_templates.mainActivityLines2);
    }

    // After 'GeneratedPluginRegistrant ...' add the following lines
    if (line.contains('GeneratedPluginRegistrant.registerWith(this);')) {
      newLines.add(xml_templates.mainActivityLines3);
    }
  }

  mainActivityFile.writeAsString(newLines.join('\n'));
}
