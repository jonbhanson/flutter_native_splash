import 'package:flutter_native_splash/constants.dart';
import 'package:flutter_native_splash/exceptions.dart';
import 'package:flutter_native_splash/templates.dart' as templates;
import 'package:image/image.dart';
import 'dart:io';

// Image template
class AndroidDrawableTemplate {
  final String directoryName;
  final double divider;

  AndroidDrawableTemplate({this.directoryName, this.divider});
}

final List<AndroidDrawableTemplate> splashImages = <AndroidDrawableTemplate>[
  AndroidDrawableTemplate(directoryName: 'drawable-mdpi', divider: 2.0),
  AndroidDrawableTemplate(directoryName: 'drawable-hdpi', divider: 1.8),
  AndroidDrawableTemplate(directoryName: 'drawable-xhdpi', divider: 1.4),
  AndroidDrawableTemplate(directoryName: 'drawable-xxhdpi', divider: 1.2),
  AndroidDrawableTemplate(directoryName: 'drawable-xxxhdpi', divider: 1.0),
];

/// Create Android splash screen
createSplash(String imagePath, String color) async {
  _applyImage(imagePath);
  await _applyLaunchBackgroundXml();

  // _applyColor will update launch_background.xml which may be created in _applyLaunchBackgroundXml
  // that's why we need to await _applyLaunchBackgroundXml()
  _applyColor(color);
  _applyStylesXml();

  await _applyMainActivityUpdate();
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
  Image newFile = copyResize(
    image,
    width: image.width ~/ template.divider,
    height: image.height ~/ template.divider,
    interpolation: Interpolation.linear,
  );

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
    if (lines.isEmpty) {
      throw InvalidNativeFile("File 'launch_background.xml' contains 0 lines.");
    } else {
      lines.insert(lines.length - 1, templates.androidLaunchBackgroundItemXml);
    }
  }

  await launchBackgroundFile.writeAsString(lines.join('\n'));
}

/// Creates launch_background.xml with splash image path
Future _createLaunchBackgroundFileWithImagePath() async {
  File file = await File(androidLaunchBackgroundFile).create(recursive: true);
  return await file.writeAsString(templates.androidLaunchBackgroundXml);
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
    if (lines.isEmpty) {
      throw InvalidNativeFile("File 'colors.xml' contains 0 lines.");
    } else {
      lines.insert(
          lines.length - 1, '\t<color name="splash_color">$color</color>');
    }
  }

  colorsFile.writeAsStringSync(lines.join('\n'));
}

/// Creates a colors.xml file if it was missing from android/app/src/main/res/values/colors.xml
void _createColorsFile(String color) {
  File(androidColorsFile).create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(templates.androidColorsXml).then((File file) {
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
  await launchBackgroundFile.writeAsString(lines.join('\n'));
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
    if (lines.isEmpty) {
      throw InvalidNativeFile("File 'styles.xml' contains 0 lines.");
    } else {
      lines.insert(endStyleLine, templates.androidStylesItemXml);
    }
  }

  await stylesFile.writeAsString(lines.join('\n'));
}

/// Creates styles.xml with full screen property
void _createStylesFileWithImagePath() {
  File(androidStylesFile).create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(templates.androidStylesXml);
  });
}

/// Update MainActivity adding code to remove full screen mode after app load
Future _applyMainActivityUpdate() async {
  final String language = await _javaOrKotlin();
  String mainActivityPath;

  if (language == 'java') {
    mainActivityPath = await _getMainActivityJavaPath();
  } else if (language == 'kotlin') {
    mainActivityPath = await _getMainActivityKotlinPath();
  }

  final File mainActivityFile = File(mainActivityPath);
  final List<String> lines = await mainActivityFile.readAsLines();

  if (_needToUpdateMainActivity(language, lines)) {
    _addMainActivitySplashLines(language, mainActivityFile, lines);
  }
}

Future _javaOrKotlin() async {
  var mainActivityJavaPath = await _getMainActivityJavaPath();
  var mainActivityKotlinPath = await _getMainActivityKotlinPath();

  if (File(mainActivityJavaPath).existsSync()) {
    return 'java';
  } else if (File(mainActivityKotlinPath).existsSync()) {
    return 'kotlin';
  } else {
    throw CantFindMainActivityPath(
        "Not able to determinate MainActivity path. Maybe the problem is your package path OR your AndroidManifest.xml 'package' attribute on manifest.");
  }
}

/// Get MainActivity.java path based on package name on AndroidManifest.xml
Future _getMainActivityJavaPath() async {
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
    return false;
  }

  return mainActivityPath;
}

/// Get MainActivity.kt path based on package name on AndroidManifest.xml
Future _getMainActivityKotlinPath() async {
  File androidManifest = File(androidManifestFile);
  final List<String> lines = await androidManifest.readAsLines();

  bool foundPath = false;
  String mainActivityPath = 'android/app/src/main/kotlin/';

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

      mainActivityPath += "$path1/$path2/$path3/MainActivity.kt";
      foundPath = true;
      break;
    }
  }

  if (!foundPath) {
    return false;
  }

  return mainActivityPath;
}

/// Check if MainActivity needs to be updated with code required for splash screen
bool _needToUpdateMainActivity(String language, List<String> lines) {
  bool foundExisting = false;

  String javaLine = 'boolean flutter_native_splash = true;';
  String kotlinLine = 'val flutter_native_splash = true';

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // if file contains our variable we're assuming it contains all required code
    if (line.contains((language == 'java') ? javaLine : kotlinLine)) {
      foundExisting = true;
      break;
    }
  }

  return !foundExisting;
}

/// Add in MainActivity the code required for removing full screen mode of splash screen after app loaded
void _addMainActivitySplashLines(
    String language, File mainActivityFile, List<String> lines) {
  List<String> newLines = [];

  List<String> javaReferenceLines = [
    'public class MainActivity extends FlutterActivity {',
    'super.onCreate(savedInstanceState);',
    'GeneratedPluginRegistrant.registerWith(this);',
  ];

  List<String> kotlinReferenceLines = [
    'class MainActivity: FlutterActivity() {',
    'super.onCreate(savedInstanceState)',
    'GeneratedPluginRegistrant.registerWith(this)',
  ];

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (language == 'java') {
      // Before 'public class ...' add the following lines
      if (line.contains(javaReferenceLines[0])) {
        newLines.add(templates.androidMainActivityJavaLines1);
      }

      newLines.add(line);

      // After 'super.onCreate ...' add the following lines
      if (line.contains(javaReferenceLines[1])) {
        newLines.add(templates.androidMainActivityJavaLines2);
      }

      // After 'GeneratedPluginRegistrant ...' add the following lines
      if (line.contains(javaReferenceLines[2])) {
        newLines.add(templates.androidMainActivityJavaLines3);
      }
    }

    if (language == 'kotlin') {
      // Before 'class MainActivity ...' add the following lines
      if (line.contains(kotlinReferenceLines[0])) {
        newLines.add(templates.androidMainActivityKotlinLines1);
      }

      newLines.add(line);

      // After 'super.onCreate ...' add the following lines
      if (line.contains(kotlinReferenceLines[1])) {
        newLines.add(templates.androidMainActivityKotlinLines2);
      }

      // After 'GeneratedPluginRegistrant ...' add the following lines
      if (line.contains(kotlinReferenceLines[2])) {
        newLines.add(templates.androidMainActivityKotlinLines3);
      }
    }
  }

  mainActivityFile.writeAsString(newLines.join('\n'));
}
