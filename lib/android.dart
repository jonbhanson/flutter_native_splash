part of flutter_native_splash_supported_platform;

/// Image template
class _AndroidDrawableTemplate {
  final String directoryName;
  final double divider;
  _AndroidDrawableTemplate(
      {required this.directoryName, required this.divider});
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
Future<void> _createAndroidSplash(
    {required String imagePath,
    required String darkImagePath,
    required String color,
    required String darkColor,
    required String gravity,
    required bool fullscreen}) async {
  if (imagePath.isNotEmpty) {
    await _applyImageAndroid(imagePath: imagePath);
  }
  if (darkImagePath.isNotEmpty) {
    await _applyImageAndroid(imagePath: darkImagePath, dark: true);
  }

  await _applyLaunchBackgroundXml(
    gravity: gravity,
    launchBackgroundFilePath: _androidLaunchBackgroundFile,
    showImage: imagePath.isNotEmpty,
  );
  await _applyColor(color: color, colorFile: _androidColorsFile);
  await _overwriteLaunchBackgroundWithNewSplashColor(
      color: color, launchBackgroundFilePath: _androidLaunchBackgroundFile);

  if (darkColor.isNotEmpty) {
    await _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidLaunchDarkBackgroundFile,
      showImage: imagePath.isNotEmpty,
    );
    await _applyColor(color: darkColor, colorFile: _androidColorsDarkFile);
    await _overwriteLaunchBackgroundWithNewSplashColor(
        color: color,
        launchBackgroundFilePath: _androidLaunchDarkBackgroundFile);
  }

  if (await Directory(_androidV21DrawableFolder).exists()) {
    await _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidV21LaunchBackgroundFile,
      showImage: imagePath.isNotEmpty,
    );
    await _overwriteLaunchBackgroundWithNewSplashColor(
        color: color,
        launchBackgroundFilePath: _androidV21LaunchBackgroundFile);
    if (darkColor.isNotEmpty) {
      await _applyLaunchBackgroundXml(
        gravity: gravity,
        launchBackgroundFilePath: _androidV21LaunchDarkBackgroundFile,
        showImage: imagePath.isNotEmpty,
      );
      await _overwriteLaunchBackgroundWithNewSplashColor(
          color: color,
          launchBackgroundFilePath: _androidV21LaunchDarkBackgroundFile);
    }
  }

  await _applyStylesXml(fullScreen: fullscreen);
}

/// Create splash screen as drawables for multiple screens (dpi)
Future<void> _applyImageAndroid(
    {required String imagePath, bool dark = false}) async {
  print('[Android] Creating ' + (dark ? 'dark mode ' : '') + 'splash images');

  final file = File(imagePath);

  if (!file.existsSync()) {
    throw _NoImageFileFoundException('The file $imagePath was not found.');
  }

  final image = decodeImage(File(imagePath).readAsBytesSync());
  if (image == null) {
    throw _NoImageFileFoundException('The file $imagePath could not be read.');
  }

  for (var template in dark ? _splashImagesDark : _splashImages) {
    _saveImageAndroid(template: template, image: image);
  }
}

/// Saves splash screen image to the project
/// Note: Do not change interpolation unless you end up with better results
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void _saveImageAndroid(
    {required _AndroidDrawableTemplate template, required Image image}) {
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
Future _applyLaunchBackgroundXml({
  required String gravity,
  required String launchBackgroundFilePath,
  required bool showImage,
}) {
  final launchBackgroundFile = File(launchBackgroundFilePath);

  if (launchBackgroundFile.existsSync()) {
    if (launchBackgroundFile.existsSync()) {
      print('[Android] Updating ' +
          launchBackgroundFilePath +
          ' with splash image path');
      return _updateLaunchBackgroundFileWithImagePath(
          launchBackgroundFilePath: launchBackgroundFilePath,
          gravity: gravity,
          showImage: showImage);
    }

    return Future.value(false);
  } else {
    print('[Android] No ' +
        launchBackgroundFilePath +
        ' file found in your Android project');
    print('[Android] Creating ' +
        launchBackgroundFilePath +
        ' file and adding it to your Android project');
    return _createLaunchBackgroundFileWithImagePath(
        gravity: gravity,
        launchBackgroundFilePath: launchBackgroundFilePath,
        showImage: showImage);
  }
}

/// Updates launch_background.xml adding splash image path
Future _updateLaunchBackgroundFileWithImagePath(
    {required String launchBackgroundFilePath,
    required String gravity,
    required bool showImage}) async {
  final launchBackgroundFile = File(launchBackgroundFilePath);
  var launchBackgroundDocument;
  if (launchBackgroundFile.existsSync()) {
    launchBackgroundDocument =
        XmlDocument.parse(await launchBackgroundFile.readAsString());
  } else {
    await launchBackgroundFile.create(recursive: true);
    launchBackgroundDocument = XmlDocument.parse(_androidLaunchBackgroundXml);
  }

  final layerList = launchBackgroundDocument.getElement('layer-list');
  final items = layerList.children;

  var removeNodes = <XmlNode>[];
  items.forEach((XmlNode item) {
    // Remove file template comments:
    if (item.nodeType == XmlNodeType.COMMENT) {
      _androidLaunchBackgroundXmlExampleLines.forEach((element) {
        if (item.toString().contains(element)) removeNodes.add(item);
      });
    }
    // Remove existing bitmaps:
    if (item.children.isNotEmpty) {
      var existingBitmap = item.getElement('bitmap');
      if (existingBitmap != null) removeNodes.add(item);
    }
  });
  removeNodes.forEach(items.remove);

  if (showImage) {
    var splashItem =
        XmlDocument.parse(_androidLaunchBackgroundItemXml).rootElement.copy();
    splashItem.getElement('bitmap')?.setAttribute('android:gravity', gravity);
    items.add(splashItem);
  }
  launchBackgroundFile.writeAsStringSync(
      launchBackgroundDocument.toXmlString(pretty: true, indent: '    '));
}

/// Creates launch_background.xml with splash image path
Future _createLaunchBackgroundFileWithImagePath(
    {required String gravity,
    required String launchBackgroundFilePath,
    required bool showImage}) async {
  var file = await File(launchBackgroundFilePath).create(recursive: true);
  var fileContent = XmlDocument.parse(_androidLaunchBackgroundXml);

  if (showImage) {
    var splashItem =
        XmlDocument.parse(_androidLaunchBackgroundItemXml).rootElement.copy();
    splashItem.getElement('bitmap')?.setAttribute('android:gravity', gravity);
    fileContent.getElement('layer-list')?.children.add(splashItem);
  }
  return await file
      .writeAsString(fileContent.toXmlString(pretty: true, indent: '    '));
}

/// Create or update colors.xml adding splash screen background color
Future<void> _applyColor({color, required String colorFile}) async {
  var colorsXml = File(colorFile);

  color = '#' + color;
  if (colorsXml.existsSync()) {
    print('[Android] Updating ' +
        colorFile +
        ' with color for splash screen background');
    _updateColorsFileWithColor(colorsFile: colorsXml, color: color);
  } else {
    print('[Android] No ' + colorFile + ' file found in your Android project');
    print('[Android] Creating ' +
        colorFile +
        ' file and adding it to your Android project');
    _createColorsFile(color: color, colorsXml: colorsXml);
  }
}

/// Updates the colors.xml with the splash screen background color
void _updateColorsFileWithColor(
    {required File colorsFile, required String color}) {
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
void _createColorsFile({required String color, required File colorsXml}) {
  colorsXml.create(recursive: true).then((File colorsFile) {
    colorsFile.writeAsString(_androidColorsXml).then((File file) {
      _updateColorsFileWithColor(colorsFile: colorsFile, color: color);
    });
  });
}

/// Updates the line which specifies the splash screen background color within the AndroidManifest.xml
/// with the new icon name (only if it has changed)
///
/// Note: default color = "splash_color"
Future _overwriteLaunchBackgroundWithNewSplashColor(
    {required String color, required String launchBackgroundFilePath}) async {
  final launchBackgroundFile = File(launchBackgroundFilePath);
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
Future<void> _applyStylesXml({required bool fullScreen}) async {
  final stylesFile = File(_androidStylesFile);

  if (!stylesFile.existsSync()) {
    print('[Android] No styles.xml file found in your Android project');
    print(
        '[Android] Creating styles.xml file and adding it to your Android project');
    _createStylesFileWithImagePath(stylesFile: stylesFile);
  }
  print('[Android] Updating styles.xml with full screen mode setting');
  await _updateStylesFile(fullScreen: fullScreen, stylesFile: stylesFile);
}

/// Updates styles.xml adding full screen property
Future<void> _updateStylesFile(
    {required bool fullScreen, required File stylesFile}) async {
  final stylesDocument = XmlDocument.parse(await stylesFile.readAsString());
  final styles = stylesDocument.findAllElements('style');
  if (styles.length == 1) {
    print('[Android] Only 1 style in styles.xml. Flutter V2 embedding has 2 '
        'styles by default.  Full screen mode not supported in Flutter V1 '
        'embedding.  Skipping update of styles.xml with fullscreen mode');
    return;
  }
  var found = true;
  final launchTheme = styles.firstWhere(
      (element) => (element.attributes.any((attribute) =>
          attribute.name.toString() == 'name' &&
          attribute.value == 'LaunchTheme')), orElse: () {
    found = false;
    return XmlElement(XmlName('dummy'));
  });
  if (found) {
    final fullScreenElement = launchTheme.children.firstWhere(
        (element) => (element.attributes.any((attribute) {
              return attribute.name.toString() == 'name' &&
                  attribute.value == 'android:windowFullscreen';
            })), orElse: () {
      found = false;
      return XmlElement(XmlName('dummy'));
    });
    if (found) {
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
void _createStylesFileWithImagePath({required File stylesFile}) {
  stylesFile.createSync(recursive: true);
  stylesFile.writeAsStringSync(_androidStylesXml);
}
