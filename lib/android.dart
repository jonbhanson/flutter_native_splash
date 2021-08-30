part of flutter_native_splash;

/// Image template
class _AndroidDrawableTemplate {
  final String directoryName;
  final double pixelDensity;
  _AndroidDrawableTemplate(
      {required this.directoryName, required this.pixelDensity});
}

@visibleForTesting
final List<_AndroidDrawableTemplate> androidSplashImages =
    <_AndroidDrawableTemplate>[
  _AndroidDrawableTemplate(directoryName: 'drawable-mdpi', pixelDensity: 1),
  _AndroidDrawableTemplate(directoryName: 'drawable-hdpi', pixelDensity: 1.5),
  _AndroidDrawableTemplate(directoryName: 'drawable-xhdpi', pixelDensity: 2),
  _AndroidDrawableTemplate(directoryName: 'drawable-xxhdpi', pixelDensity: 3),
  _AndroidDrawableTemplate(directoryName: 'drawable-xxxhdpi', pixelDensity: 4),
];

@visibleForTesting
final List<_AndroidDrawableTemplate> androidSplashImagesDark =
    <_AndroidDrawableTemplate>[
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-mdpi', pixelDensity: 1),
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-hdpi', pixelDensity: 1.5),
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-xhdpi', pixelDensity: 2),
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-xxhdpi', pixelDensity: 3),
  _AndroidDrawableTemplate(
      directoryName: 'drawable-night-xxxhdpi', pixelDensity: 4),
];

/// Create Android splash screen
void _createAndroidSplash({
  required String? imagePath,
  required String? darkImagePath,
  required String color,
  required String darkColor,
  required String gravity,
  required bool fullscreen,
  required String? backgroundImage,
  required String? darkBackgroundImage,
  required bool android12,
}) {
  if (imagePath != null) {
    _applyImageAndroid(imagePath: imagePath);
  }
  if (darkImagePath != null) {
    _applyImageAndroid(imagePath: darkImagePath, dark: true);
  }

  _applyLaunchBackgroundXml(
    gravity: gravity,
    launchBackgroundFilePath: _androidLaunchBackgroundFile,
    showImage: imagePath != null,
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
      showImage: imagePath != null,
    );
  }

  if (Directory(_androidV21DrawableFolder).existsSync()) {
    _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidV21LaunchBackgroundFile,
      showImage: imagePath != null,
    );
    if (darkColor.isNotEmpty) {
      _applyLaunchBackgroundXml(
        gravity: gravity,
        launchBackgroundFilePath: _androidV21LaunchDarkBackgroundFile,
        showImage: imagePath != null,
      );
    }
  }

  if (android12) {
    _applyStylesXml(
        fullScreen: fullscreen,
        file: _androidV31StylesFile,
        template: _androidV31StylesXml);
    _applyStylesXml(
        fullScreen: fullscreen,
        file: _androidV31StylesNightFile,
        template: _androidV31StylesNightXml);
  } else {
    var file = File(_androidV31StylesFile);
    if (file.existsSync()) file.deleteSync();
    file = File(_androidV31StylesNightFile);
    if (file.existsSync()) file.deleteSync();
  }

  _applyStylesXml(
      fullScreen: fullscreen,
      file: _androidStylesFile,
      template: _androidStylesXml);
  _applyStylesXml(
      fullScreen: fullscreen,
      file: _androidNightStylesFile,
      template: _androidStylesNightXml);
}

/// Create splash screen as drawables for multiple screens (dpi)
void _applyImageAndroid({required String imagePath, bool dark = false}) {
  print('[Android] Creating ' + (dark ? 'dark mode ' : '') + 'splash images');

  final image = decodeImage(File(imagePath).readAsBytesSync());
  if (image == null) {
    print('The file $imagePath could not be read.');
    exit(1);
  }

  for (var template in dark ? androidSplashImagesDark : androidSplashImages) {
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
    width: image.width * template.pixelDensity ~/ 4,
    height: image.height * template.pixelDensity ~/ 4,
    interpolation: Interpolation.linear,
  );

  var file =
      File(_androidResFolder + template.directoryName + '/' + 'splash.png');
  file.createSync(recursive: true);
  file.writeAsBytesSync(encodePng(newFile));
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
void _applyStylesXml(
    {required bool fullScreen,
    required String file,
    required String template}) {
  final stylesFile = File(file);

  if (!stylesFile.existsSync()) {
    print('[Android] No styles.xml file found in your Android project');
    print('[Android] Creating styles.xml file and adding it to your Android '
        'project');
    stylesFile.createSync(recursive: true);
    stylesFile.writeAsStringSync(template);
  }
  print('[Android] Updating styles.xml with full screen mode setting');
  _updateStylesFile(fullScreen: fullScreen, stylesFile: stylesFile);
}

/// Updates styles.xml adding full screen property
void _updateStylesFile({required bool fullScreen, required File stylesFile}) {
  final stylesDocument = XmlDocument.parse(stylesFile.readAsStringSync());
  final resources = stylesDocument.getElement('resources');
  final styles = resources?.findElements('style');
  if (styles?.length == 1) {
    print('[Android] Only 1 style in styles.xml. Flutter V2 embedding has 2 '
        'styles by default.  Full screen mode not supported in Flutter V1 '
        'embedding.  Skipping update of styles.xml with fullscreen mode');
    return;
  }

  XmlElement launchTheme;
  try {
    launchTheme = styles!.singleWhere((element) => (element.attributes.any(
        (attribute) =>
            attribute.name.toString() == 'name' &&
            attribute.value == 'LaunchTheme')));
  } on StateError {
    print('LaunchTheme was not found in styles.xml. Skipping fullscreen'
        'mode');
    return;
  }

  launchTheme.children
      .removeWhere((element) => (element.attributes.any((attribute) {
            return attribute.name.toString() == 'name' &&
                attribute.value == 'android:windowFullscreen';
          })));

  launchTheme.children.add(XmlElement(
      XmlName('item'),
      [XmlAttribute(XmlName('name'), 'android:windowFullscreen')],
      [XmlText(fullScreen.toString())]));

  stylesFile.writeAsStringSync(
      stylesDocument.toXmlString(pretty: true, indent: '    '));
}
