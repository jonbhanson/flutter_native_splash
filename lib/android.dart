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
void _createAndroidSplash({
  required String imagePath,
  required String darkImagePath,
  required String color,
  required String darkColor,
  required String gravity,
  required bool fullscreen,
  required String backgroundImage,
  required String darkBackgroundImage,
}) {
  if (imagePath.isNotEmpty) {
    _applyImageAndroid(imagePath: imagePath);
  }
  if (darkImagePath.isNotEmpty) {
    _applyImageAndroid(imagePath: darkImagePath, dark: true);
  }

  _applyLaunchBackgroundXml(
    gravity: gravity,
    launchBackgroundFilePath: _androidLaunchBackgroundFile,
    showImage: imagePath.isNotEmpty,
  );

  _createBackground(
    colorString: color,
    darkColorString: darkColor,
    darkBackgroundImageSource: darkBackgroundImage,
    backgroundImageSource: backgroundImage,
    darkBackgroundImageDestination:
        _androidNightDrawableFolder + 'background.png',
    backgroundImageDestination: _androidDrawableFolder + 'background.png',
  );

  _createBackground(
    colorString: color,
    darkColorString: darkColor,
    darkBackgroundImageSource: darkBackgroundImage,
    backgroundImageSource: backgroundImage,
    darkBackgroundImageDestination:
        _androidNightV21DrawableFolder + 'background.png',
    backgroundImageDestination: _androidV21DrawableFolder + 'background.png',
  );

  if (darkColor.isNotEmpty) {
    _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidLaunchDarkBackgroundFile,
      showImage: imagePath.isNotEmpty,
    );
  }

  if (Directory(_androidV21DrawableFolder).existsSync()) {
    _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidV21LaunchBackgroundFile,
      showImage: imagePath.isNotEmpty,
    );
    if (darkColor.isNotEmpty) {
      _applyLaunchBackgroundXml(
        gravity: gravity,
        launchBackgroundFilePath: _androidV21LaunchDarkBackgroundFile,
        showImage: imagePath.isNotEmpty,
      );
    }
  }

  _applyStylesXml(fullScreen: fullscreen);
}

/// Create splash screen as drawables for multiple screens (dpi)
void _applyImageAndroid({required String imagePath, bool dark = false}) {
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

/// Updates launch_background.xml adding splash image path
void _applyLaunchBackgroundXml(
    {required String launchBackgroundFilePath,
    required String gravity,
    required bool showImage}) {
  print('[Android] Updating $launchBackgroundFilePath with splash image path');
  final launchBackgroundFile = File(launchBackgroundFilePath);
  var launchBackgroundDocument;
  launchBackgroundFile.createSync(recursive: true);
  launchBackgroundDocument = XmlDocument.parse(_androidLaunchBackgroundXml);

  final layerList = launchBackgroundDocument.getElement('layer-list');
  final List<XmlNode> items = layerList.children;

  if (showImage) {
    var splashItem =
        XmlDocument.parse(_androidLaunchItemXml).rootElement.copy();
    splashItem.getElement('bitmap')?.setAttribute('android:gravity', gravity);
    items.add(splashItem);
  }
  launchBackgroundFile.writeAsStringSync(
      launchBackgroundDocument.toXmlString(pretty: true, indent: '    '));
}

/// Create or update styles.xml full screen mode setting
void _applyStylesXml({required bool fullScreen}) {
  final stylesFile = File(_androidStylesFile);

  if (!stylesFile.existsSync()) {
    print('[Android] No styles.xml file found in your Android project');
    print(
        '[Android] Creating styles.xml file and adding it to your Android project');
    _createStylesFileWithImagePath(stylesFile: stylesFile);
  }
  print('[Android] Updating styles.xml with full screen mode setting');
  _updateStylesFile(fullScreen: fullScreen, stylesFile: stylesFile);
}

/// Updates styles.xml adding full screen property
void _updateStylesFile({required bool fullScreen, required File stylesFile}) {
  final stylesDocument = XmlDocument.parse(stylesFile.readAsStringSync());
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
