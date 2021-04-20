part of flutter_native_splash;

// Image template
class _IosLaunchImageTemplate {
  final String fileName;
  final double divider;

  _IosLaunchImageTemplate({required this.fileName, required this.divider});
}

final List<_IosLaunchImageTemplate> iOSSplashImages = <_IosLaunchImageTemplate>[
  _IosLaunchImageTemplate(fileName: 'LaunchImage.png', divider: 3),
  _IosLaunchImageTemplate(fileName: 'LaunchImage@2x.png', divider: 1.5),
  _IosLaunchImageTemplate(
      fileName: 'LaunchImage@3x.png', divider: 1), // original image must be @3x
];

final List<_IosLaunchImageTemplate> iOSSplashImagesDark =
    <_IosLaunchImageTemplate>[
  _IosLaunchImageTemplate(fileName: 'LaunchImageDark.png', divider: 3),
  _IosLaunchImageTemplate(fileName: 'LaunchImageDark@2x.png', divider: 1.5),
  _IosLaunchImageTemplate(fileName: 'LaunchImageDark@3x.png', divider: 1),
  // original image must be @3x
];

/// Create iOS splash screen
void _createiOSSplash({
  required String imagePath,
  required String darkImagePath,
  required String color,
  required String darkColor,
  List<String>? plistFiles,
  required String iosContentMode,
  required bool fullscreen,
  required String backgroundImage,
  required String darkBackgroundImage,
}) {
  if (imagePath.isNotEmpty) {
    _applyImageiOS(imagePath: imagePath);
  } else {
    final splashImage = Image(1, 1);
    iOSSplashImages.forEach((template) {
      var file = File(_iOSAssetsLaunchImageFolder + template.fileName);
      file.createSync(recursive: true);
      file.writeAsBytesSync(encodePng(splashImage));
    });
  }

  if (darkImagePath.isNotEmpty) {
    _applyImageiOS(imagePath: darkImagePath, dark: true);
  } else {
    iOSSplashImagesDark.forEach((template) {
      final file = File(_iOSAssetsLaunchImageFolder + template.fileName);
      if (file.existsSync()) file.deleteSync();
    });
  }

  var launchImageFile = File(_iOSAssetsLaunchImageFolder + 'Contents.json');
  launchImageFile.createSync(recursive: true);
  launchImageFile.writeAsStringSync(
      darkImagePath.isNotEmpty ? _iOSContentsJsonDark : _iOSContentsJson);

  _applyLaunchScreenStoryboard(
      imagePath: imagePath, iosContentMode: iosContentMode);
  _createBackground(
    colorString: color,
    darkColorString: darkColor,
    darkBackgroundImageSource: darkBackgroundImage,
    backgroundImageSource: backgroundImage,
    darkBackgroundImageDestination:
        _iOSAssetsLaunchImageBackgroundFolder + 'darkbackground.png',
    backgroundImageDestination:
        _iOSAssetsLaunchImageBackgroundFolder + 'background.png',
  );

  var backgroundImageFile =
      File(_iOSAssetsLaunchImageBackgroundFolder + 'Contents.json');
  backgroundImageFile.createSync(recursive: true);

  backgroundImageFile.writeAsStringSync(darkColor.isNotEmpty
      ? _iOSLaunchBackgroundDarkJson
      : _iOSLaunchBackgroundJson);

  _applyInfoPList(plistFiles: plistFiles, fullscreen: fullscreen);
}

/// Create splash screen images for original size, @2x and @3x
void _applyImageiOS({required String imagePath, bool dark = false}) {
  print('[iOS] Creating ' + (dark ? 'dark mode ' : '') + 'splash images');

  final image = decodeImage(File(imagePath).readAsBytesSync());
  if (image == null) {
    print(imagePath + ' could not be loaded.');
    exit(1);
  }
  for (var template in dark ? iOSSplashImagesDark : iOSSplashImages) {
    _saveImageiOS(template: template, image: image);
  }
}

/// Saves splash screen image to the project
void _saveImageiOS(
    {required _IosLaunchImageTemplate template, required Image image}) {
  var newFile = copyResize(
    image,
    width: image.width ~/ template.divider,
    height: image.height ~/ template.divider,
    interpolation: Interpolation.linear,
  );

  var file = File(_iOSAssetsLaunchImageFolder + template.fileName);
  file.createSync(recursive: true);
  file.writeAsBytesSync(encodePng(newFile));
}

/// Update LaunchScreen.storyboard adding width, height and color
void _applyLaunchScreenStoryboard(
    {required String imagePath, required String iosContentMode}) {
  final file = File(_iOSLaunchScreenStoryboardFile);

  if (file.existsSync()) {
    print('[iOS] Updating LaunchScreen.storyboard with width, and height');
    return _updateLaunchScreenStoryboard(
        imagePath: imagePath, iosContentMode: iosContentMode);
  } else {
    print('[iOS] No LaunchScreen.storyboard file found in your iOS project');
    print('[iOS] Creating LaunchScreen.storyboard file and adding it '
        'to your iOS project');
    return _createLaunchScreenStoryboard(
        imagePath: imagePath, iosContentMode: iosContentMode);
  }
}

/// Updates LaunchScreen.storyboard adding splash image path
void _updateLaunchScreenStoryboard(
    {required String imagePath, required String iosContentMode}) {
  // Load the data
  final file = File(_iOSLaunchScreenStoryboardFile);
  final xmlDocument = XmlDocument.parse(file.readAsStringSync());
  final documentData = xmlDocument.getElement('document');

  // Find the view that contains the splash image
  final view =
      documentData?.descendants.whereType<XmlElement>().firstWhere((element) {
    return (element.name.qualified == 'view' &&
        element.getAttribute('id') == 'Ze5-6b-2t3');
  });
  if (view == null) {
    print('Default Flutter view Ze5-6b-2t3 not found. '
        'Did you modify your default LaunchScreen.storyboard file?');
    exit(1);
  }

  // Find the splash imageView
  final subViews = view.getElement('subviews');
  if (subViews == null) {
    print('Not able to find "subviews" in LaunchScreen.storyboard. Image for '
        'splash screen not updated. Did you modify your default '
        'LaunchScreen.storyboard file?');
    exit(1);
  }
  final imageView = subViews.children.whereType<XmlElement>().firstWhere(
      (element) => (element.name.qualified == 'imageView' &&
          element.getAttribute('image') == 'LaunchImage'), orElse: () {
    print('Not able to find "LaunchImage" in LaunchScreen.storyboard. Image '
        'for splash screen not updated. Did you modify your default '
        'LaunchScreen.storyboard file?');
    exit(1);
  });
  subViews.children.whereType<XmlElement>().firstWhere(
      (element) => (element.name.qualified == 'imageView' &&
          element.getAttribute('image') == 'LaunchBackground'), orElse: () {
    subViews.children.insert(
        0, XmlDocument.parse(_iOSLaunchBackgroundSubview).rootElement.copy());
    return XmlElement(XmlName(''));
  });
  // Update the fill property
  imageView.setAttribute('contentMode', iosContentMode);

  // Find the resources
  final resources = documentData?.getElement('resources');
  var launchImageResource = resources?.children
      .whereType<XmlElement>()
      .firstWhere(
          (element) => (element.name.qualified == 'image' &&
              element.getAttribute('name') == 'LaunchImage'), orElse: () {
    print('Not able to find "LaunchImage" in LaunchScreen.storyboard. Image '
        'for splash screen not updated. Did you modify your default '
        'LaunchScreen.storyboard file?');
    exit(1);
  });

  resources?.children.whereType<XmlElement>().firstWhere(
      (element) => (element.name.qualified == 'image' &&
          element.getAttribute('name') == 'LaunchBackground'), orElse: () {
    // If the color has not been set via background image, set it here:

    resources.children.add(XmlDocument.parse(
            '<image name="LaunchBackground" width="1" height="1"/>')
        .rootElement
        .copy());
    return XmlElement(XmlName(''));
  });

  view.children.remove(view.getElement('constraints'));
  view.children.add(
      XmlDocument.parse(_iOSLaunchBackgroundConstraints).rootElement.copy());

  if (imagePath.isNotEmpty) {
    final image = decodeImage(File(imagePath).readAsBytesSync());
    if (image == null) {
      print(imagePath + ' could not be loaded.');
      exit(1);
    }
    launchImageResource?.setAttribute('width', image.width.toString());
    launchImageResource?.setAttribute('height', image.height.toString());
  }

  file.writeAsStringSync(xmlDocument.toXmlString(pretty: true, indent: '    '));
}

/// Creates LaunchScreen.storyboard with splash image path
void _createLaunchScreenStoryboard(
    {required String imagePath, required String iosContentMode}) {
  var file = File(_iOSLaunchScreenStoryboardFile);
  file.createSync(recursive: true);
  file.writeAsStringSync(_iOSLaunchScreenStoryboardContent);
  return _updateLaunchScreenStoryboard(
      imagePath: imagePath, iosContentMode: iosContentMode);
}

void _createBackground({
  required String colorString,
  required String darkColorString,
  required String backgroundImageSource,
  required String darkBackgroundImageSource,
  required String backgroundImageDestination,
  required String darkBackgroundImageDestination,
}) {
  if (colorString.isNotEmpty) {
    var background = Image(1, 1);
    var redChannel = int.parse(colorString.substring(0, 2), radix: 16);
    var greenChannel = int.parse(colorString.substring(2, 4), radix: 16);
    var blueChannel = int.parse(colorString.substring(4, 6), radix: 16);
    background.fill(
        0xFF000000 + (blueChannel << 16) + (greenChannel << 8) + redChannel);
    var file = File(backgroundImageDestination);
    file.createSync(recursive: true);
    file.writeAsBytesSync(encodePng(background));
  } else if (backgroundImageSource.isNotEmpty) {
    // Copy will not work if the directory does not exist, so createSync
    // will ensure that the directory exists.
    File(backgroundImageDestination).createSync(recursive: true);
    File(backgroundImageSource).copySync(backgroundImageDestination);
  } else {
    throw Exception('No color string or background image!');
  }

  if (darkColorString.isNotEmpty) {
    var background = Image(1, 1);
    var redChannel = int.parse(darkColorString.substring(0, 2), radix: 16);
    var greenChannel = int.parse(darkColorString.substring(2, 4), radix: 16);
    var blueChannel = int.parse(darkColorString.substring(4, 6), radix: 16);
    background.fill(
        0xFF000000 + (blueChannel << 16) + (greenChannel << 8) + redChannel);
    var file = File(darkBackgroundImageDestination);
    file.createSync(recursive: true);
    file.writeAsBytesSync(encodePng(background));
  } else if (darkBackgroundImageSource.isNotEmpty) {
    // Copy will not work if the directory does not exist, so createSync
    // will ensure that the directory exists.
    File(darkBackgroundImageDestination).createSync(recursive: true);
    File(darkBackgroundImageSource).copySync(darkBackgroundImageDestination);
  } else {
    final file = File(darkBackgroundImageDestination);
    if (file.existsSync()) file.deleteSync();
  }
}

/// Update Info.plist for status bar behaviour (hidden/visible)
void _applyInfoPList({List<String>? plistFiles, required bool fullscreen}) {
  if (plistFiles == null) {
    plistFiles = [];
    plistFiles.add(_iOSInfoPlistFile);
  }

  plistFiles.forEach((plistFile) {
    if (!File(plistFile).existsSync()) {
      print('File $plistFile not found.  If you renamed the file, make sure to'
          ' specify it in the info_plist_files section of your '
          'flutter_native_splash configuration.');
      exit(1);
    }

    print('[iOS] Updating $plistFile for status bar hidden/visible');
    _updateInfoPlistFile(plistFile: plistFile, fullscreen: fullscreen);
  });
}

/// Update Infop.list with status bar hidden directive
void _updateInfoPlistFile(
    {required String plistFile, required bool fullscreen}) {
  // Load the data
  final file = File(plistFile);
  final xmlDocument = XmlDocument.parse(file.readAsStringSync());
  final dict = xmlDocument.getElement('plist')?.getElement('dict');
  if (dict == null) {
    throw Exception(plistFile + ' plist dict element not found');
  }

  var elementFound = true;
  final uIStatusBarHidden =
      dict.children.whereType<XmlElement>().firstWhere((element) {
    return (element.text == 'UIStatusBarHidden');
  }, orElse: () {
    final builder = XmlBuilder();
    builder.element('key', nest: () {
      builder.text('UIStatusBarHidden');
    });
    dict.children.add(builder.buildFragment());
    dict.children.add(XmlElement(XmlName(fullscreen.toString())));
    elementFound = false;
    return XmlElement(XmlName(''));
  });

  if (elementFound) {
    var index = dict.children.indexOf(uIStatusBarHidden);
    var uIStatusBarHiddenValue = dict.children[index + 1].following
        .firstWhere((element) => element.nodeType == XmlNodeType.ELEMENT);
    uIStatusBarHiddenValue.replace(XmlElement(XmlName(fullscreen.toString())));
  }

  elementFound = true;
  if (fullscreen) {
    final uIViewControllerBasedStatusBarAppearance =
        dict.children.whereType<XmlElement>().firstWhere((element) {
      return (element.text == 'UIViewControllerBasedStatusBarAppearance');
    }, orElse: () {
      final builder = XmlBuilder();
      builder.element('key', nest: () {
        builder.text('UIViewControllerBasedStatusBarAppearance');
      });
      dict.children.add(builder.buildFragment());
      dict.children.add(XmlElement(XmlName((!fullscreen).toString())));
      elementFound = false;
      return XmlElement(XmlName(''));
    });

    if (elementFound) {
      var index =
          dict.children.indexOf(uIViewControllerBasedStatusBarAppearance);

      var uIViewControllerBasedStatusBarAppearanceValue = dict
          .children[index + 1].following
          .firstWhere((element) => element.nodeType == XmlNodeType.ELEMENT);
      uIViewControllerBasedStatusBarAppearanceValue
          .replace(XmlElement(XmlName('false')));
    }
  }

  file.writeAsStringSync(xmlDocument.toXmlString(pretty: true, indent: '	'));
}
