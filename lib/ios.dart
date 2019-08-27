import 'package:color/color.dart';
import 'package:flutter_native_splash/constants.dart';
import 'package:flutter_native_splash/exceptions.dart';
import 'package:flutter_native_splash/templates.dart' as templates;
import 'package:image/image.dart' as img;
import 'dart:io';

// Image template
class IosLaunchImageTemplate {
  final String fileName;
  final double divider;

  IosLaunchImageTemplate({this.fileName, this.divider});
}

final List<IosLaunchImageTemplate> splashImages = <IosLaunchImageTemplate>[
  IosLaunchImageTemplate(fileName: 'LaunchImage.png', divider: 3),
  IosLaunchImageTemplate(fileName: 'LaunchImage@2x.png', divider: 2),
  IosLaunchImageTemplate(
      fileName: 'LaunchImage@3x.png', divider: 1), // original image must be @3x
];

/// Create iOS splash screen
createSplash(String imagePath, String color) async {
  await _applyImage(imagePath);
  await _applyLaunchScreenStoryboard(imagePath, color);
  await _applyInfoPList();
  await _applyAppDelegate();
}

/// Create splash screen images for original size, @2x and @3x
void _applyImage(String imagePath) {
  print("[iOS] Creating splash images");

  final File file = File(imagePath);

  if (!file.existsSync()) {
    throw NoImageFileFoundException("The file $imagePath was not found.");
  }

  final img.Image image = img.decodeImage(File(imagePath).readAsBytesSync());

  for (IosLaunchImageTemplate template in splashImages) {
    _saveImage(template, image);
  }
}

/// Saves splash screen image to the project
void _saveImage(IosLaunchImageTemplate template, img.Image image) {
  img.Image newFile = img.copyResize(
    image,
    width: image.width ~/ template.divider,
    height: image.height ~/ template.divider,
    interpolation: img.Interpolation.linear,
  );

  File(iOSAssetsLaunchImageFolder + template.fileName)
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(img.encodePng(newFile));
  });
}

/// Update LaunchScreen.storyboard adding width, height and color
Future _applyLaunchScreenStoryboard(String imagePath, String color) {
  if (!color.contains("#")) {
    color = "#" + color;
  }

  final File file = File(iOSLaunchScreenStoryboardFile);

  if (file.existsSync()) {
    print(
        "[iOS] Updating LaunchScreen.storyboard with width, height and color");
    return _updateLaunchScreenStoryboard(imagePath, color);
  } else {
    print("[iOS] No LaunchScreen.storyboard file found in your iOS project");
    print(
        "[iOS] Creating LaunchScreen.storyboard file and adding it to your iOS project");
    return _createLaunchScreenStoryboard(imagePath, color);
  }
}

/// Updates LaunchScreen.storyboard adding splash image path
Future _updateLaunchScreenStoryboard(String imagePath, String color) async {
  final File file = File(iOSLaunchScreenStoryboardFile);
  final List<String> lines = await file.readAsLines();

  bool foundExistingColor = false;
  int colorLine;

  bool foundExistingImage = false;
  int imageLine;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (line.contains('<color key="backgroundColor"')) {
      foundExistingColor = true;
      colorLine = x;
    }

    if (line.contains('<image name="LaunchImage"')) {
      foundExistingImage = true;
      imageLine = x;
    }
  }

  // Found the color line, replace with new color information
  if (foundExistingColor) {
    HexColor hex = HexColor(color);
    double appleRed = hex.r / 255;
    double appleGreen = hex.g / 255;
    double appleBlue = hex.b / 255;

    lines[colorLine] =
        '                        <color key="backgroundColor" red="$appleRed" green="$appleGreen" blue="$appleBlue" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>';
  } else {
    throw LaunchScreenStoryboardModified(
        "Not able to find 'backgroundColor' color tag in LaunchScreen.storyboard. Background color for splash screen not updated. Did you modify your default LaunchScreen.storyboard file?");
  }

  // Found the image line, replace with new image information
  if (foundExistingImage) {
    final File file = File(imagePath);

    if (!file.existsSync()) {
      throw NoImageFileFoundException("The file $imagePath was not found.");
    }

    final img.Image image = img.decodeImage(File(imagePath).readAsBytesSync());
    int width = image.width;
    int height = image.height;

    lines[imageLine] =
        '        <image name="LaunchImage" width="$width" height="$height"/>';
  } else {
    throw LaunchScreenStoryboardModified(
        "Not able to find 'LaunchImage' image tag in LaunchScreen.storyboard. Image for splash screen not updated. Did you modify your default LaunchScreen.storyboard file?");
  }

  await file.writeAsString(lines.join('\n'));
}

/// Creates LaunchScreen.storyboard with splash image path
Future _createLaunchScreenStoryboard(String imagePath, String color) async {
  File file = await File(iOSLaunchScreenStoryboardFile).create(recursive: true);
  await file.writeAsString(templates.iOSLaunchScreenStoryboardContent);

  return _updateLaunchScreenStoryboard(imagePath, color);
}

/// Update Info.plist for status bar behaviour (hidden/visible)
Future _applyInfoPList() async {
  final File infoPlistFile = File(iOSInfoPlistFile);
  final List<String> lines = await infoPlistFile.readAsLines();

  if (_needToUpdateInfoPlist(lines)) {
    print("[iOS] Updating Info.plist for status bar hidden/visible");
    await _updateInfoPlistFile(infoPlistFile, lines);
  }
}

/// Check if Info.plist needs to be updated with code required for status bar hidden
bool _needToUpdateInfoPlist(List<String> lines) {
  bool foundExisting = false;

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // if file contains our variable we're assuming it contains all required code
    // it's okay to check only for the key because the key doesn't come on default create
    if (line.contains('<key>UIStatusBarHidden</key>')) {
      foundExisting = true;
      break;
    }
  }

  return !foundExisting;
}

/// Update Infop.list with status bar hidden directive
Future _updateInfoPlistFile(File infoPlistFile, List<String> lines) async {
  List<String> newLines = [];

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // Before '</dict>' add the following lines
    if (line.contains('</dict>')) {
      newLines.add(templates.iOSInfoPlistLines);
    }

    newLines.add(line);
  }

  await infoPlistFile.writeAsString(newLines.join('\n'));
}

/// Add the code required for removing full screen mode of splash screen after app loaded
Future _applyAppDelegate() async {
  String language = await _objectiveCOrSwift();
  String appDelegatePath;

  if (language == 'objective-c') {
    appDelegatePath = iOSAppDelegateObjCFile;
  } else if (language == 'swift') {
    appDelegatePath = iOSAppDelegateSwiftFile;
  }

  final File appDelegateFile = File(appDelegatePath);
  final List<String> lines = await appDelegateFile.readAsLines();

  if (_needToUpdateAppDelegate(language, lines)) {
    print("[iOS] Updating AppDelegate for status bar hidden/visible");
    await _updateAppDelegate(language, appDelegateFile, lines);
  }
}

Future _objectiveCOrSwift() async {
  if (File(iOSAppDelegateObjCFile).existsSync()) {
    return 'objective-c';
  } else if (File(iOSAppDelegateSwiftFile).existsSync()) {
    return 'swift';
  } else {
    throw CantFindAppDelegatePath("Not able to determinate AppDelegate path.");
  }
}

/// Check if AppDelegate needs to be updated with code required for splash screen
bool _needToUpdateAppDelegate(String language, List<String> lines) {
  bool foundExisting = false;

  String objectiveCLine = 'int flutter_native_splash = 1;';
  String swiftLine = 'var flutter_native_splash = 1';

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    // if file contains our variable we're assuming it contains all required code
    if (line
        .contains((language == 'objective-c') ? objectiveCLine : swiftLine)) {
      foundExisting = true;
      break;
    }
  }

  return !foundExisting;
}

/// Update AppDelegate with code to remove status bar hidden property after app loaded
Future _updateAppDelegate(
    String language, File appDelegateFile, List<String> lines) async {
  List<String> newLines = [];

  String objectiveCReferenceLine =
      '[GeneratedPluginRegistrant registerWithRegistry:self];';
  String swiftReferenceLine = 'GeneratedPluginRegistrant.register(with: self)';

  for (int x = 0; x < lines.length; x++) {
    String line = lines[x];

    if (language == 'objective-c') {
      // Before '[GeneratedPlugin ...' add the following lines
      if (line.contains(objectiveCReferenceLine)) {
        newLines.add(templates.iOSAppDelegateObjectiveCLines);
      }

      newLines.add(line);
    }

    if (language == 'swift') {
      // Before 'GeneratedPlugin ...' add the following lines
      if (line.contains(swiftReferenceLine)) {
        newLines.add(templates.iOSAppDelegateSwiftLines);
      }

      newLines.add(line);
    }
  }

  await appDelegateFile.writeAsString(newLines.join('\n'));
}
