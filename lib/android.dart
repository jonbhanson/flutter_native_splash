part of flutter_native_splash_supported_platform;

/// Image template
class _AndroidDrawableTemplate {
  final String directoryName;
  final double divider;
  _AndroidDrawableTemplate({this.directoryName, this.divider});
}

final List<_AndroidDrawableTemplate> _splashImages = <_AndroidDrawableTemplate>[
  _AndroidDrawableTemplate(directoryName: 'drawable-mdpi', divider: 2.0),
  _AndroidDrawableTemplate(directoryName: 'drawable-hdpi', divider: 1.8),
  _AndroidDrawableTemplate(directoryName: 'drawable-xhdpi', divider: 1.4),
  _AndroidDrawableTemplate(directoryName: 'drawable-xxhdpi', divider: 1.2),
  _AndroidDrawableTemplate(directoryName: 'drawable-xxxhdpi', divider: 1.0),
];

final List<_AndroidDrawableTemplate> _splashImagesDark =
    <_AndroidDrawableTemplate>[
  _AndroidDrawableTemplate(directoryName: 'drawable-night-mdpi', divider: 2.0),
  _AndroidDrawableTemplate(directoryName: 'drawable-night-hdpi', divider: 1.8),
  _AndroidDrawableTemplate(directoryName: 'drawable-night-xhdpi', divider: 1.4),
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-xxhdpi', divider: 1.2),
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-xxxhdpi', divider: 1.0),
];

/// Create Android splash screen
void _createAndroidSplash(String imagePath, String darkImagePath, String color,
    String darkColor, bool fill, bool androidDisableFullscreen) async {
  if (imagePath.isNotEmpty) {
    await _applyImageAndroid(imagePath);
  }
  if (darkImagePath.isNotEmpty) {
    await _applyImageAndroid(darkImagePath, dark: true);
  }

  await _applyLaunchBackgroundXml(imagePath, fill);
  if (darkColor.isNotEmpty) {
    await _applyLaunchBackgroundXml(darkImagePath, fill, dark: true);
  }

  // _applyColor will update launch_background.xml which may be created in _applyLaunchBackgroundXml
  // that's why we need to await _applyLaunchBackgroundXml()
  await _applyColor(color);
  if (darkColor.isNotEmpty) {
    await _applyColor(darkColor, dark: true);
  }

  await _applyStylesXml(!androidDisableFullscreen);
}

/// Create splash screen as drawables for multiple screens (dpi)
void _applyImageAndroid(String imagePath, {bool dark = false}) {
  print('[Android] Creating ' + (dark ? 'dark mode ' : '') + 'splash images');

  final file = File(imagePath);

  if (!file.existsSync()) {
    throw _NoImageFileFoundException('The file $imagePath was not found.');
  }

  final image = decodeImage(File(imagePath).readAsBytesSync());

  for (var template in dark ? _splashImagesDark : _splashImages) {
    _saveImageAndroid(template, image);
  }
}

/// Saves splash screen image to the project
/// Note: Do not change interpolation unless you end up with better results
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void _saveImageAndroid(_AndroidDrawableTemplate template, Image image) {
  var newFile = copyResize(
    image,
    width: image.width ~/ template.divider,
    height: image.height ~/ template.divider,
    interpolation: Interpolation.linear,
  );

  File(_androidResFolder + template.directoryName + '/' + 'splash.png')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodePng(newFile));
  });
}

/// Create or update launch_background.xml adding splash image path
Future _applyLaunchBackgroundXml(String imagePath, bool fill,
    {bool dark = false}) {
  final launchBackgroundFile = File(
      dark ? _androidLaunchDarkBackgroundFile : _androidLaunchBackgroundFile);

  if (launchBackgroundFile.existsSync()) {
    if (imagePath.isNotEmpty) {
      print('[Android] Updating ' +
          (dark ? 'dark mode ' : '') +
          'launch_background.xml with splash image path');
      return _updateLaunchBackgroundFileWithImagePath(fill, dark);
    }

    return Future.value(false);
  } else {
    print('[Android] No ' +
        (dark ? 'dark mode ' : '') +
        'launch_background.xml file found in your Android project');
    print('[Android] Creating ' +
        (dark ? 'dark mode ' : '') +
        'launch_background.xml file and adding it to your Android project');
    return _createLaunchBackgroundFileWithImagePath(imagePath, fill, dark);
  }
}

/// Updates launch_background.xml adding splash image path
Future _updateLaunchBackgroundFileWithImagePath(bool fill, bool dark) async {
  final launchBackgroundFile = dark
      ? File(_androidLaunchDarkBackgroundFile)
      : File(_androidLaunchBackgroundFile);
  final lines = await launchBackgroundFile.readAsLines();
  var foundExisting = false;

  for (var x = 0; x < lines.length; x++) {
    var line = lines[x];

    if (line.contains('android:src="@drawable/splash"') ||
        line.contains('android:drawable="@color/splash_color"')) {
      foundExisting = true;
      break;
    }
  }

  // Add new line if we didn't find an existing value
  if (!foundExisting) {
    if (lines.isEmpty) {
      throw _InvalidNativeFile(
          "File 'launch_background.xml' contains 0 lines.");
    } else {
      if (fill == null || !fill) {
        lines.insert(lines.length - 1, _androidLaunchBackgroundItemXml);
      } else {
        lines.insert(lines.length - 1, _androidLaunchBackgroundItemXmlFill);
      }
    }
  }

  await launchBackgroundFile.writeAsString(lines.join('\n'));
}

/// Creates launch_background.xml with splash image path
Future _createLaunchBackgroundFileWithImagePath(
    String imagePath, bool fill, bool dark) async {
  var file = await File(dark
          ? _androidLaunchDarkBackgroundFile
          : _androidLaunchBackgroundFile)
      .create(recursive: true);
  String fileContent;

  if (fill == null || !fill) {
    fileContent = _androidLaunchBackgroundXml;

    if (imagePath.isEmpty) {
      fileContent = fileContent.replaceAll(_androidLaunchBackgroundItemXml, '');
    }
  } else {
    fileContent = _androidLaunchBackgroundXmlFill;

    if (imagePath.isEmpty) {
      fileContent = fileContent.replaceAll(_androidLaunchBackgroundXmlFill, '');
    }
  }
  return await file.writeAsString(fileContent);
}

/// Create or update colors.xml adding splash screen background color
void _applyColor(color, {bool dark = false}) {
  final colorsXml = File(dark ? _androidColorsDarkFile : _androidColorsFile);

  if (!color.contains('#')) {
    color = '#' + color;
  }

  if (colorsXml.existsSync()) {
    print('[Android] Updating ' +
        (dark ? 'dark mode ' : '') +
        'colors.xml with color for splash screen background');
    _updateColorsFileWithColor(colorsXml, color);
  } else {
    print('[Android] No ' +
        (dark ? 'dark mode ' : '') +
        'colors.xml file found in your Android project');
    print('[Android] Creating ' +
        (dark ? 'dark mode ' : '') +
        'colors.xml file and adding it to your Android project');
    _createColorsFile(color, colorsXml);
  }

  _overwriteLaunchBackgroundWithNewSplashColor(color, dark);
}

/// Updates the colors.xml with the splash screen background color
void _updateColorsFileWithColor(File colorsFile, String color) {
  final lines = colorsFile.readAsLinesSync();
  var foundExisting = false;

  for (var x = 0; x < lines.length; x++) {
    var line = lines[x];

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
      throw _InvalidNativeFile("File 'colors.xml' contains 0 lines.");
    } else {
      lines.insert(
          lines.length - 1, '\t<color name="splash_color">$color</color>');
    }
  }

  colorsFile.writeAsStringSync(lines.join('\n'));
}

/// Creates a colors.xml file if it was missing from android/app/src/main/res/values/colors.xml
void _createColorsFile(String color, File colorsXml) {
  colorsXml.create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(_androidColorsXml).then((File file) {
      _updateColorsFileWithColor(colorsFile, color);
    });
  });
}

/// Updates the line which specifies the splash screen background color within the AndroidManifest.xml
/// with the new icon name (only if it has changed)
///
/// Note: default color = "splash_color"
Future _overwriteLaunchBackgroundWithNewSplashColor(
    String color, bool dark) async {
  final launchBackgroundFile = File(
      dark ? _androidLaunchDarkBackgroundFile : _androidLaunchBackgroundFile);
  final lines = await launchBackgroundFile.readAsLines();

  for (var x = 0; x < lines.length; x++) {
    var line = lines[x];
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
Future<void> _applyStylesXml(bool fullScreen) async {
  final stylesFile = File(_androidStylesFile);

  if (!stylesFile.existsSync()) {
    print('[Android] No styles.xml file found in your Android project');
    print(
        '[Android] Creating styles.xml file and adding it to your Android project');
    _createStylesFileWithImagePath(stylesFile);
  }
  print('[Android] Updating styles.xml with full screen mode setting');
  await _updateStylesFile(fullScreen, stylesFile);
}

/// Updates styles.xml adding full screen property
Future<void> _updateStylesFile(bool fullScreen, File stylesFile) async {
  final stylesDocument = XmlDocument.parse(await stylesFile.readAsString());
  final styles = stylesDocument.findAllElements('style');
  if (styles.length == 1) {
    print('[Android] Only 1 style in styles.xml. Flutter V2 embedding has 2 '
        'styles by default.  Full screen mode not supported in Flutter V1 '
        'embedding.  Skipping update of styles.xml with fullscreen mode');
    return;
  }
  final launchTheme = styles.firstWhere(
      (element) => (element.attributes.any((attribute) =>
          attribute.name.toString() == 'name' &&
          attribute.value == 'LaunchTheme')),
      orElse: () => null);
  if (launchTheme != null) {
    final fullScreenElement = launchTheme.children.firstWhere(
        (element) => (element.attributes.any((attribute) {
              return attribute.name.toString() == 'name' &&
                  attribute.value == 'android:windowFullscreen';
            })),
        orElse: () => null);
    if (fullScreenElement == null) {
      launchTheme.children.add(XmlElement(
          XmlName('item'),
          [XmlAttribute(XmlName('name'), 'android:windowFullscreen')],
          [XmlText(fullScreen.toString())]));
    } else {
      fullScreenElement.children.clear();
      fullScreenElement.children.add(XmlText(fullScreen.toString()));
    }
    stylesFile.writeAsStringSync(
        stylesDocument.toXmlString(pretty: true, indent: '    '));
    return;
  }
  print('[Android] Failed to update styles.xml with full screen mode setting');
}

/// Creates styles.xml with full screen property
void _createStylesFileWithImagePath(File stylesFile) {
  stylesFile.createSync(recursive: true);
  stylesFile.writeAsStringSync(_androidStylesXml);
}
