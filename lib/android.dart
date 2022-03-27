part of flutter_native_splash_cli;

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
  required String? android12ImagePath,
  required String? android12DarkImagePath,
  required String? brandingImagePath,
  required String? brandingDarkImagePath,
  required String? color,
  required String? darkColor,
  required String gravity,
  required String brandingGravity,
  required bool fullscreen,
  required String? backgroundImage,
  required String? darkBackgroundImage,
  required String? android12IconBackgroundColor,
  required String? darkAndroid12IconBackgroundColor,
}) {
  if (imagePath != null) {
    _applyImageAndroid(imagePath: imagePath);
  }
  if (darkImagePath != null) {
    _applyImageAndroid(imagePath: darkImagePath, dark: true);
  }

  //create resources for branding image if provided
  if (brandingImagePath != null) {
    _applyImageAndroid(imagePath: brandingImagePath, fileName: 'branding.png');
  }
  if (brandingDarkImagePath != null) {
    _applyImageAndroid(
      imagePath: brandingDarkImagePath,
      dark: true,
      fileName: 'branding.png',
    );
  }

  //create android 12 image if provided.  (otherwise uses launch icon)
  if (android12ImagePath != null) {
    _applyImageAndroid(
        imagePath: android12ImagePath, fileName: 'android12splash.png');
  }

  if (android12DarkImagePath != null) {
    _applyImageAndroid(
        imagePath: android12DarkImagePath,
        dark: true,
        fileName: 'android12splash.png');
  }

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

  print('[Android] Updating launch background(s) with splash image path...');

  _applyLaunchBackgroundXml(
    gravity: gravity,
    launchBackgroundFilePath: _androidLaunchBackgroundFile,
    showImage: imagePath != null,
    showBranding: brandingImagePath != null,
    brandingGravity: brandingGravity,
  );

  if (darkColor != null || darkBackgroundImage != null) {
    _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidLaunchDarkBackgroundFile,
      showImage: imagePath != null,
      showBranding: brandingImagePath != null,
      brandingGravity: brandingGravity,
    );
  }

  if (Directory(_androidV21DrawableFolder).existsSync()) {
    _applyLaunchBackgroundXml(
      gravity: gravity,
      launchBackgroundFilePath: _androidV21LaunchBackgroundFile,
      showImage: imagePath != null,
      showBranding: brandingImagePath != null,
      brandingGravity: brandingGravity,
    );
    if (darkColor != null || darkBackgroundImage != null) {
      _applyLaunchBackgroundXml(
        gravity: gravity,
        launchBackgroundFilePath: _androidV21LaunchDarkBackgroundFile,
        showImage: imagePath != null,
        showBranding: brandingImagePath != null,
        brandingGravity: brandingGravity,
      );
    }
  }

  print('[Android] Updating styles...');
  _applyStylesXml(
    fullScreen: fullscreen,
    file: _androidV31StylesFile,
    template: _androidV31StylesXml,
    android12BackgroundColor: color,
    android12ImagePath: android12ImagePath,
    android12IconBackgroundColor: android12IconBackgroundColor,
    android12BrandingImagePath: brandingImagePath,
  );

  if (darkColor != null) {
    _applyStylesXml(
      fullScreen: fullscreen,
      file: _androidV31StylesNightFile,
      template: _androidV31StylesNightXml,
      android12BackgroundColor: darkColor,
      android12ImagePath: android12DarkImagePath,
      android12IconBackgroundColor: darkAndroid12IconBackgroundColor,
      android12BrandingImagePath: brandingDarkImagePath,
    );
  }

  _applyStylesXml(
    fullScreen: fullscreen,
    file: _androidStylesFile,
    template: _androidStylesXml,
  );

  if (darkColor != null || darkBackgroundImage != null) {
    _applyStylesXml(
      fullScreen: fullscreen,
      file: _androidNightStylesFile,
      template: _androidStylesNightXml,
    );
  }
}

/// Create splash screen as drawables for multiple screens (dpi)
void _applyImageAndroid(
    {required String imagePath,
    bool dark = false,
    String fileName = 'splash.png'}) {
  print('[Android] Creating ' +
      (dark ? 'dark mode ' : '') +
      '${fileName.split('.')[0]} images');

  final image = decodeImage(File(imagePath).readAsBytesSync());
  if (image == null) {
    print('The file $imagePath could not be read.');
    exit(1);
  }

  for (var template in dark ? androidSplashImagesDark : androidSplashImages) {
    _saveImageAndroid(template: template, image: image, fileName: fileName);
  }
}

/// Saves splash screen image to the project
/// Note: Do not change interpolation unless you end up with better results
/// https://github.com/fluttercommunity/flutter_launcher_icons/issues/101#issuecomment-495528733
void _saveImageAndroid(
    {required _AndroidDrawableTemplate template,
    required Image image,
    required fileName}) {
  //added file name attribute to make this method generic for splash image and branding image.
  var newFile = copyResize(
    image,
    width: image.width * template.pixelDensity ~/ 4,
    height: image.height * template.pixelDensity ~/ 4,
    interpolation: Interpolation.linear,
  );

  var file = File('$_androidResFolder${template.directoryName}/$fileName');
  // File(_androidResFolder + template.directoryName + '/' + 'splash.png');
  file.createSync(recursive: true);
  file.writeAsBytesSync(encodePng(newFile));
}

/// Updates launch_background.xml adding splash image path
void _applyLaunchBackgroundXml(
    {required String launchBackgroundFilePath,
    required String gravity,
    required bool showImage,
    bool showBranding = false,
    String brandingGravity = 'bottom'}) {
  print('[Android]    - ' + launchBackgroundFilePath);
  final launchBackgroundFile = File(launchBackgroundFilePath);
  launchBackgroundFile.createSync(recursive: true);
  var launchBackgroundDocument = XmlDocument.parse(_androidLaunchBackgroundXml);

  final layerList = launchBackgroundDocument.getElement('layer-list');
  final List<XmlNode> items = layerList!.children;

  if (showImage) {
    var splashItem =
        XmlDocument.parse(_androidLaunchItemXml).rootElement.copy();
    splashItem.getElement('bitmap')?.setAttribute('android:gravity', gravity);
    items.add(splashItem);
  }

  if (showBranding && gravity != brandingGravity) {
    //add branding when splash image and branding image are not at the same position
    var brandingItem =
        XmlDocument.parse(_androidBrandingItemXml).rootElement.copy();
    if (brandingGravity == 'bottomRight') {
      brandingGravity = 'bottom|right';
    } else if (brandingGravity == 'bottomLeft') {
      brandingGravity = 'bottom|left';
    } else if (brandingGravity != 'bottom') {
      print(
          '$brandingGravity illegal property defined for the branding mode. Setting back to default.');
      brandingGravity = 'bottom';
    }
    brandingItem
        .getElement('bitmap')
        ?.setAttribute('android:gravity', brandingGravity);
    items.add(brandingItem);
  }

  launchBackgroundFile.writeAsStringSync(
      launchBackgroundDocument.toXmlString(pretty: true, indent: '    '));
}

/// Create or update styles.xml full screen mode setting
void _applyStylesXml({
  required bool fullScreen,
  required String file,
  required String template,
  String? android12BackgroundColor,
  String? android12ImagePath,
  String? android12IconBackgroundColor,
  String? android12BrandingImagePath,
}) {
  final stylesFile = File(file);
  print('[Android]    - ' + file);
  if (!stylesFile.existsSync()) {
    print('[Android] No $file found in your Android project');
    print('[Android] Creating $file and adding it to your Android project');
    stylesFile.createSync(recursive: true);
    stylesFile.writeAsStringSync(template);
  }

  _updateStylesFile(
    fullScreen: fullScreen,
    stylesFile: stylesFile,
    android12BackgroundColor: android12BackgroundColor,
    android12ImagePath: android12ImagePath,
    android12IconBackgroundColor: android12IconBackgroundColor,
    android12BrandingImagePath: android12BrandingImagePath,
  );
}

/// Updates styles.xml adding full screen property
Future<void> _updateStylesFile({
  required bool fullScreen,
  required File stylesFile,
  required String? android12BackgroundColor,
  required String? android12ImagePath,
  required String? android12IconBackgroundColor,
  required String? android12BrandingImagePath,
}) async {
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

  replaceElement(
      launchTheme: launchTheme,
      name: 'android:forceDarkAllowed',
      value: "false");

  replaceElement(
      launchTheme: launchTheme,
      name: 'android:windowFullscreen',
      value: fullScreen.toString());

  // In Android 12, the color must be set directly in the styles.xml
  if (android12BackgroundColor != null) {
    replaceElement(
        launchTheme: launchTheme,
        name: 'android:windowSplashScreenBackground',
        value: '#' + android12BackgroundColor);
  }

  if (android12BrandingImagePath != null) {
    replaceElement(
        launchTheme: launchTheme,
        name: 'android:windowSplashScreenBrandingImage',
        value: '@drawable/branding');
  }

  if (android12ImagePath != null) {
    replaceElement(
        launchTheme: launchTheme,
        name: 'android:windowSplashScreenAnimatedIcon',
        value: '@drawable/android12splash');
  }

  if (android12IconBackgroundColor != null) {
    replaceElement(
        launchTheme: launchTheme,
        name: 'android:windowSplashScreenIconBackgroundColor',
        value: '#' + android12IconBackgroundColor);
  }

  stylesFile.writeAsStringSync(
      stylesDocument.toXmlString(pretty: true, indent: '    '));
}

void replaceElement({
  required XmlElement launchTheme,
  required String name,
  required String value,
}) {
  launchTheme.children.removeWhere((element) => element.attributes.any(
      (attribute) =>
          attribute.name.toString() == 'name' && attribute.value == name));

  launchTheme.children.add(XmlElement(XmlName('item'),
      [XmlAttribute(XmlName('name'), name)], [XmlText(value)]));
}
