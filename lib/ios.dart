part of 'cli_commands.dart';

// Image template
class _IosLaunchImageTemplate {
  final String fileName;
  final double pixelDensity;

  _IosLaunchImageTemplate({required this.fileName, required this.pixelDensity});
}

final List<_IosLaunchImageTemplate> _iOSSplashImages =
    <_IosLaunchImageTemplate>[
  _IosLaunchImageTemplate(fileName: 'LaunchImage.png', pixelDensity: 1),
  _IosLaunchImageTemplate(fileName: 'LaunchImage@2x.png', pixelDensity: 2),
  _IosLaunchImageTemplate(
    fileName: 'LaunchImage@3x.png',
    pixelDensity: 3,
  ), // original image must be @4x
];

final List<_IosLaunchImageTemplate> _iOSSplashImagesDark =
    <_IosLaunchImageTemplate>[
  _IosLaunchImageTemplate(fileName: 'LaunchImageDark.png', pixelDensity: 1),
  _IosLaunchImageTemplate(fileName: 'LaunchImageDark@2x.png', pixelDensity: 2),
  _IosLaunchImageTemplate(fileName: 'LaunchImageDark@3x.png', pixelDensity: 3),
  // original image must be @3x
];

//Resource files for branding assets
final List<_IosLaunchImageTemplate> _iOSBrandingImages =
    <_IosLaunchImageTemplate>[
  _IosLaunchImageTemplate(fileName: 'BrandingImage.png', pixelDensity: 1),
  _IosLaunchImageTemplate(fileName: 'BrandingImage@2x.png', pixelDensity: 2),
  _IosLaunchImageTemplate(
    fileName: 'BrandingImage@3x.png',
    pixelDensity: 3,
  ), // original image must be @4x
];
final List<_IosLaunchImageTemplate> _iOSBrandingImagesDark =
    <_IosLaunchImageTemplate>[
  _IosLaunchImageTemplate(fileName: 'BrandingImageDark.png', pixelDensity: 1),
  _IosLaunchImageTemplate(
    fileName: 'BrandingImageDark@2x.png',
    pixelDensity: 2,
  ),
  _IosLaunchImageTemplate(
    fileName: 'BrandingImageDark@3x.png',
    pixelDensity: 3,
  ),
  // original image must be @3x
];

/// Create iOS splash screen
void _createiOSSplash({
  required String? imagePath,
  required String? darkImagePath,
  String? brandingImagePath,
  String? brandingBottomPadding,
  String? brandingDarkImagePath,
  required String? color,
  required String? darkColor,
  List<String>? plistFiles,
  required String iosContentMode,
  String? iosBrandingContentMode,
  required bool fullscreen,
  required String? backgroundImage,
  required String? darkBackgroundImage,
}) {
  if (imagePath != null) {
    _applyImageiOS(imagePath: imagePath, list: _iOSSplashImages);
  } else {
    final splashImage = Image(width: 1, height: 1);
    for (final template in _iOSSplashImages) {
      final file =
          File(_flavorHelper.iOSAssetsLaunchImageFolder + template.fileName);
      file.createSync(recursive: true);
      file.writeAsBytesSync(encodePng(splashImage));
    }
  }

  if (darkImagePath != null) {
    _applyImageiOS(
      imagePath: darkImagePath,
      dark: true,
      list: _iOSSplashImagesDark,
    );
  } else {
    for (final template in _iOSSplashImagesDark) {
      final file =
          File(_flavorHelper.iOSAssetsLaunchImageFolder + template.fileName);
      if (file.existsSync()) file.deleteSync();
    }
  }

  if (brandingImagePath != null) {
    _applyImageiOS(
      imagePath: brandingImagePath,
      list: _iOSBrandingImages,
      targetPath: _flavorHelper.iOSAssetsBrandingImageFolder,
    );
  } else {
    if (Directory(_flavorHelper.iOSAssetsBrandingImageFolder).existsSync()) {
      Directory(_flavorHelper.iOSAssetsBrandingImageFolder)
          .delete(recursive: true);
    }
  }
  if (brandingDarkImagePath != null) {
    _applyImageiOS(
      imagePath: brandingDarkImagePath,
      dark: true,
      list: _iOSBrandingImagesDark,
      targetPath: _flavorHelper.iOSAssetsBrandingImageFolder,
    );
  } else {
    for (final template in _iOSBrandingImagesDark) {
      final file =
          File(_flavorHelper.iOSAssetsBrandingImageFolder + template.fileName);
      if (file.existsSync()) file.deleteSync();
    }
  }

  final launchImageFile =
      File('${_flavorHelper.iOSAssetsLaunchImageFolder}Contents.json');
  launchImageFile.createSync(recursive: true);
  launchImageFile.writeAsStringSync(
    darkImagePath != null ? _iOSContentsJsonDark : _iOSContentsJson,
  );

  if (brandingImagePath != null) {
    final brandingImageFile =
        File('${_flavorHelper.iOSAssetsBrandingImageFolder}Contents.json');
    brandingImageFile.createSync(recursive: true);
    brandingImageFile.writeAsStringSync(
      brandingDarkImagePath != null
          ? _iOSBrandingContentsJsonDark
          : _iOSBrandingContentsJson,
    );
  }

  _createLaunchScreenStoryboard(
    imagePath: imagePath,
    brandingImagePath: brandingImagePath,
    iosContentMode: iosContentMode,
    iosBrandingContentMode: iosBrandingContentMode,
    brandingBottomPadding: brandingBottomPadding,
  );
  _createBackground(
    colorString: color,
    darkColorString: darkColor,
    darkBackgroundImageSource: darkBackgroundImage,
    backgroundImageSource: backgroundImage,
    darkBackgroundImageDestination:
        '${_flavorHelper.iOSAssetsLaunchImageBackgroundFolder}darkbackground.png',
    backgroundImageDestination:
        '${_flavorHelper.iOSAssetsLaunchImageBackgroundFolder}background.png',
  );

  final backgroundImageFile = File(
    '${_flavorHelper.iOSAssetsLaunchImageBackgroundFolder}Contents.json',
  );
  backgroundImageFile.createSync(recursive: true);

  backgroundImageFile.writeAsStringSync(
    (darkColor != null || darkBackgroundImage != null)
        ? _iOSLaunchBackgroundDarkJson
        : _iOSLaunchBackgroundJson,
  );

  _applyInfoPList(plistFiles: plistFiles, fullscreen: fullscreen);
}

/// Create splash screen images for original size, @2x and @3x
void _applyImageiOS({
  required String imagePath,
  bool dark = false,
  required List<_IosLaunchImageTemplate> list,
  String? targetPath,
}) async {
  // Because the path is no longer static, targetPath can't have a default value.
  // That's why this was added, as a setup for a default value.
  targetPath ??= _flavorHelper.iOSAssetsLaunchImageFolder;

// ignore_for_file: avoid_print
  print('[iOS] Creating ${dark ? 'dark mode ' : ''} images');

  final image = decodeImage(File(imagePath).readAsBytesSync());
  if (image == null) {
    print('$imagePath could not be loaded.');
    exit(1);
  }

  await Future.wait(
    list.map(
      (template) => Isolate.run(() async {
        final newFile = copyResize(
          image,
          width: image.width * template.pixelDensity ~/ 4,
          height: image.height * template.pixelDensity ~/ 4,
          interpolation: Interpolation.average,
        );

        final file = File(targetPath! + template.fileName);
        await file.create(recursive: true);
        await file.writeAsBytes(encodePng(newFile));
      }),
    ),
  );
}

/// Updates LaunchScreen.storyboard adding splash image path
void _updateLaunchScreenStoryboard({
  required String? imagePath,
  required String iosContentMode,
  String? brandingImagePath,
  String? brandingBottomPadding,
  String? iosBrandingContentMode,
}) {
  final parsedIosContentMode = _parseIosContentMode(iosContentMode);
  String? iosBrandingContentModeValue = iosBrandingContentMode;
  Image? splashImage;

  if (imagePath != null) {
    splashImage = decodeImage(File(imagePath).readAsBytesSync());
    if (splashImage == null) {
      print('$imagePath could not be loaded.');
      exit(1);
    }
  }

  // Load the data
  final file = File(_flavorHelper.iOSLaunchScreenStoryboardFile);
  final xmlDocument = XmlDocument.parse(file.readAsStringSync());
  final documentData = xmlDocument.getElement('document');

  // Find the view that contains the splash image
  final view =
      documentData?.descendants.whereType<XmlElement>().firstWhere((element) {
    return element.name.qualified == 'view' &&
        element.getAttribute('id') == 'Ze5-6b-2t3';
  });
  if (view == null) {
    print(
      'Default Flutter view Ze5-6b-2t3 not found. '
      'Did you modify your default ${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard file?',
    );
    exit(1);
  }

  // Find the splash imageView
  final subViews = view.getElement('subviews');
  if (subViews == null) {
    print(
      'Not able to find "subviews" in ${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard. Image for '
      'splash screen not updated. Did you modify your default '
      '${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard file?',
    );
    exit(1);
  }
  final imageView = subViews.children.whereType<XmlElement>().firstWhere(
    (element) =>
        element.name.qualified == 'imageView' &&
        element.getAttribute('image') == _flavorHelper.iOSLaunchImageName,
    orElse: () {
      print(
        'Not able to find "${_flavorHelper.iOSLaunchImageName}" in ${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard. Image '
        'for splash screen not updated. Did you modify your default '
        '${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard file? [1]',
      );
      exit(1);
    },
  );
  subViews.children.whereType<XmlElement>().firstWhere(
    (element) =>
        element.name.qualified == 'imageView' &&
        element.getAttribute('image') == _flavorHelper.iOSLaunchBackgroundName,
    orElse: () {
      subViews.children.insert(
        0,
        XmlDocument.parse(_flavorHelper.iOSLaunchBackgroundSubView)
            .rootElement
            .copy(),
      );
      return XmlElement(XmlName(''));
    },
  );
  // Update the fill property
  imageView.setAttribute('contentMode', parsedIosContentMode.contentMode);

  if (!['bottom', 'bottomRight', 'bottomLeft']
      .contains(iosBrandingContentModeValue)) {
    iosBrandingContentModeValue = 'bottom';
  }
  if (brandingImagePath != null &&
      iosBrandingContentModeValue != iosContentMode) {
    final brandingImageView =
        subViews.children.whereType<XmlElement>().firstWhere(
      (element) {
        return element.name.qualified == 'imageView' &&
            element.getAttribute('image') == _flavorHelper.iOSBrandingImageName;
      },
      orElse: () {
        subViews.children.insert(
          subViews.children.length - 1,
          XmlDocument.parse(_flavorHelper.iOSBrandingSubView)
              .rootElement
              .copy(),
        );
        return XmlElement(XmlName(''));
      },
    );

    brandingImageView.setAttribute('contentMode', iosBrandingContentMode);
  }
  // Find the resources
  final resources = documentData?.getElement('resources');
  final launchImageResource =
      resources?.children.whereType<XmlElement>().firstWhere(
    (element) =>
        element.name.qualified == 'image' &&
        element.getAttribute('name') == _flavorHelper.iOSLaunchImageName,
    orElse: () {
      print(
        'Not able to find "${_flavorHelper.iOSLaunchImageName}" in ${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard. Image '
        'for splash screen not updated. Did you modify your default '
        '${_flavorHelper.iOSLaunchScreenStoryboardName}.storyboard file? [2]',
      );
      exit(1);
    },
  );

  resources?.children.whereType<XmlElement>().firstWhere(
    (element) =>
        element.name.qualified == 'image' &&
        element.getAttribute('name') == _flavorHelper.iOSLaunchBackgroundName,
    orElse: () {
      // If the color has not been set via background image, set it here:

      resources.children.add(
        XmlDocument.parse(
          '<image name="${_flavorHelper.iOSLaunchBackgroundName}" width="1" height="1"/>',
        ).rootElement.copy(),
      );
      return XmlElement(XmlName(''));
    },
  );

  view.children.remove(view.getElement('constraints'));
  final String constraints = parsedIosContentMode.anchor != null &&
          splashImage != null
      ? _buildLaunchBackgroundConstraintsWithAnchor(
          contentMode: parsedIosContentMode.contentMode,
          anchor: parsedIosContentMode.anchor!,
          imageWidth: splashImage.width,
          imageHeight: splashImage.height,
        )
      : _iOSLaunchBackgroundConstraints;
  view.children.add(
    XmlDocument.parse(constraints).rootElement.copy(),
  );

  if (splashImage != null) {
    launchImageResource?.setAttribute('width', splashImage.width.toString());
    launchImageResource?.setAttribute('height', splashImage.height.toString());
  }

  if (brandingImagePath != null) {
    final brandingImageResource =
        resources?.children.whereType<XmlElement>().firstWhere(
      (element) =>
          element.name.qualified == 'image' &&
          element.getAttribute('name') == _flavorHelper.iOSBrandingImageName,
      orElse: () {
        resources.children.add(
          XmlDocument.parse(
            '<image name="${_flavorHelper.iOSBrandingImageName}" width="1" height="1"/>',
          ).rootElement.copy(),
        );
        return XmlElement(XmlName(''));
      },
    );

    final branding = decodeImage(File(brandingImagePath).readAsBytesSync());
    if (branding == null) {
      print('$brandingImagePath could not be loaded.');
      exit(1);
    }
    brandingImageResource?.setAttribute('width', branding.width.toString());
    brandingImageResource?.setAttribute('height', branding.height.toString());

    var toParse = _iOSBrandingCenterBottomConstraints;
    if (iosBrandingContentModeValue == 'bottomLeft') {
      toParse = _iOSBrandingLeftBottomConstraints;
    } else if (iosBrandingContentModeValue == 'bottomRight') {
      toParse = _iOSBrandingRightBottomConstraints;
    }
    final element = view.getElement('constraints');

    final toParseBottomPadding =
        toParse.replaceAll("{bottom_padding}", brandingBottomPadding ?? "0");
    print("[iOS] branding bottom padding: ${brandingBottomPadding ?? "0"}");
    final doc = XmlDocument.parse(toParseBottomPadding).rootElement.copy();
    if (doc.firstChild != null) {
      print('[iOS] updating constraints with splash branding');
      for (final v in doc.children) {
        element?.children.insert(0, v.copy());
      }
    }
  }

  file.writeAsStringSync(
    '${xmlDocument.toXmlString(pretty: true, indent: '    ')}\n',
  );
}

class _IosContentModeConfig {
  final String contentMode;
  final String? anchor;

  _IosContentModeConfig({
    required this.contentMode,
    this.anchor,
  });
}

_IosContentModeConfig _parseIosContentMode(String iosContentMode) {
  final trimmed = iosContentMode.trim();

  if (!trimmed.contains('|')) {
    return _IosContentModeConfig(
      contentMode: _canonicalIosContentMode(trimmed),
    );
  }

  final separatorIndex = trimmed.indexOf('|');
  final modeToken = trimmed.substring(0, separatorIndex).trim();
  final anchorToken = trimmed.substring(separatorIndex + 1).trim();
  final canonicalMode = _canonicalIosContentMode(modeToken);
  final anchor = _normalizeIosAnchor(anchorToken);

  final bool supportsAnchors =
      canonicalMode == 'scaleAspectFit' || canonicalMode == 'scaleAspectFill';
  if (supportsAnchors && anchor != null) {
    return _IosContentModeConfig(
      contentMode: canonicalMode,
      anchor: anchor,
    );
  }

  if (supportsAnchors && anchor == null) {
    print(
      '[iOS] Unsupported anchor "$anchorToken" in ios_content_mode. '
      'Supported anchors: center, top, bottom, left, right, '
      'topLeft, topRight, bottomLeft, bottomRight.',
    );
  }

  return _IosContentModeConfig(contentMode: canonicalMode);
}

String _canonicalIosContentMode(String value) {
  final normalized = value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
  switch (normalized) {
    case 'scaletofill':
      return 'scaleToFill';
    case 'scaleaspectfit':
      return 'scaleAspectFit';
    case 'scaleaspectfill':
      return 'scaleAspectFill';
    case 'center':
      return 'center';
    case 'top':
      return 'top';
    case 'bottom':
      return 'bottom';
    case 'left':
      return 'left';
    case 'right':
      return 'right';
    case 'topleft':
      return 'topLeft';
    case 'topright':
      return 'topRight';
    case 'bottomleft':
      return 'bottomLeft';
    case 'bottomright':
      return 'bottomRight';
    default:
      return value;
  }
}

String? _normalizeIosAnchor(String value) {
  final normalized = value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
  switch (normalized) {
    case 'center':
      return 'center';
    case 'top':
      return 'top';
    case 'bottom':
      return 'bottom';
    case 'left':
      return 'left';
    case 'right':
      return 'right';
    case 'topleft':
      return 'topLeft';
    case 'topright':
      return 'topRight';
    case 'bottomleft':
      return 'bottomLeft';
    case 'bottomright':
      return 'bottomRight';
    default:
      return null;
  }
}

String _buildLaunchBackgroundConstraintsWithAnchor({
  required String contentMode,
  required String anchor,
  required int imageWidth,
  required int imageHeight,
}) {
  final relation = contentMode == 'scaleAspectFill'
      ? 'greaterThanOrEqual'
      : 'lessThanOrEqual';

  final bool isLeftAligned = anchor == 'left' ||
      anchor == 'topLeft' ||
      anchor == 'bottomLeft';
  final bool isRightAligned = anchor == 'right' ||
      anchor == 'topRight' ||
      anchor == 'bottomRight';
  final bool isTopAligned =
      anchor == 'top' || anchor == 'topLeft' || anchor == 'topRight';
  final bool isBottomAligned =
      anchor == 'bottom' || anchor == 'bottomLeft' || anchor == 'bottomRight';

  final horizontalConstraint = isLeftAligned
      ? _iOSLaunchImageHorizontalLeadingConstraint
      : isRightAligned
          ? _iOSLaunchImageHorizontalTrailingConstraint
          : _iOSLaunchImageHorizontalCenterConstraint;

  final verticalConstraint = isTopAligned
      ? _iOSLaunchImageVerticalTopConstraint
      : isBottomAligned
          ? _iOSLaunchImageVerticalBottomConstraint
          : _iOSLaunchImageVerticalCenterConstraint;

  return _iOSLaunchBackgroundAnchoredConstraints
      .replaceAll('[HORIZONTAL_CONSTRAINT]', horizontalConstraint)
      .replaceAll('[VERTICAL_CONSTRAINT]', verticalConstraint)
      .replaceAll('[IMAGE_HEIGHT]', imageHeight.toString())
      .replaceAll('[IMAGE_WIDTH]', imageWidth.toString())
      .replaceAll('[RELATION]', relation);
}

/// Creates LaunchScreen.storyboard with splash image path
void _createLaunchScreenStoryboard({
  required String? imagePath,
  required String iosContentMode,
  required String? iosBrandingContentMode,
  required String? brandingImagePath,
  required String? brandingBottomPadding,
}) {
  final file = File(_flavorHelper.iOSLaunchScreenStoryboardFile);
  file.createSync(recursive: true);
  file.writeAsStringSync(_flavorHelper.iOSLaunchScreenStoryBoardContent);

  return _updateLaunchScreenStoryboard(
    imagePath: imagePath,
    brandingImagePath: brandingImagePath,
    brandingBottomPadding: brandingBottomPadding,
    iosContentMode: iosContentMode,
    iosBrandingContentMode: iosBrandingContentMode,
  );
}

void _createBackground({
  required String? colorString,
  required String? darkColorString,
  required String? backgroundImageSource,
  required String? darkBackgroundImageSource,
  required String backgroundImageDestination,
  required String darkBackgroundImageDestination,
}) {
  if (colorString != null) {
    final background = Image(width: 1, height: 1);
    final redChannel = int.parse(colorString.substring(0, 2), radix: 16);
    final greenChannel = int.parse(colorString.substring(2, 4), radix: 16);
    final blueChannel = int.parse(colorString.substring(4, 6), radix: 16);
    background.clear(
      ColorRgb8(redChannel, greenChannel, blueChannel),
    );
    final file = File(backgroundImageDestination);
    file.createSync(recursive: true);
    file.writeAsBytesSync(encodePng(background));
  } else if (backgroundImageSource != null) {
    createBackgroundImage(
      imageDestination: backgroundImageDestination,
      imageSource: backgroundImageSource,
    );
  } else {
    throw Exception('No color string or background image!');
  }

  if (darkColorString != null) {
    final background = Image(height: 1, width: 1);
    final redChannel = int.parse(darkColorString.substring(0, 2), radix: 16);
    final greenChannel = int.parse(darkColorString.substring(2, 4), radix: 16);
    final blueChannel = int.parse(darkColorString.substring(4, 6), radix: 16);
    background.clear(ColorRgb8(redChannel, greenChannel, blueChannel));
    final file = File(darkBackgroundImageDestination);
    file.createSync(recursive: true);
    file.writeAsBytesSync(encodePng(background));
  } else if (darkBackgroundImageSource != null) {
    createBackgroundImage(
      imageDestination: darkBackgroundImageDestination,
      imageSource: darkBackgroundImageSource,
    );
  } else {
    final file = File(darkBackgroundImageDestination);
    if (file.existsSync()) file.deleteSync();
  }
}

/// Update Info.plist for status bar behaviour (hidden/visible)
void _applyInfoPList({List<String>? plistFiles, required bool fullscreen}) {
  List<String>? plistFilesValue = plistFiles;
  if (plistFilesValue == null) {
    plistFilesValue = [];
    plistFilesValue.add(_flavorHelper.iOSInfoPlistFile);
  }

  for (final plistFile in plistFilesValue) {
    if (!File(plistFile).existsSync()) {
      print(
        'File $plistFile not found.  If you renamed the file, make sure to'
        ' specify it in the info_plist_files section of your '
        'flutter_native_splash configuration.',
      );
      exit(1);
    }

    print('[iOS] Updating $plistFile for status bar hidden/visible');
    _updateInfoPlistFile(plistFile: plistFile, fullscreen: fullscreen);
  }
}

/// Update Infop.list with status bar hidden directive
void _updateInfoPlistFile({
  required String plistFile,
  required bool fullscreen,
}) {
  // Load the data
  final file = File(plistFile);
  final xmlDocument = XmlDocument.parse(file.readAsStringSync());
  final dict = xmlDocument.getElement('plist')?.getElement('dict');
  if (dict == null) {
    throw Exception('$plistFile plist dict element not found');
  }

  var elementFound = true;
  final uIStatusBarHidden = dict.children.whereType<XmlElement>().firstWhere(
    (element) {
      return element.innerText == 'UIStatusBarHidden';
    },
    orElse: () {
      final builder = XmlBuilder();
      builder.element(
        'key',
        nest: () {
          builder.text('UIStatusBarHidden');
        },
      );
      dict.children.add(builder.buildFragment());
      dict.children.add(XmlElement(XmlName(fullscreen.toString())));
      elementFound = false;
      return XmlElement(XmlName(''));
    },
  );

  if (elementFound) {
    final index = dict.children.indexOf(uIStatusBarHidden);
    final uIStatusBarHiddenValue = dict.children[index + 1].following
        .firstWhere((element) => element.nodeType == XmlNodeType.ELEMENT);
    uIStatusBarHiddenValue.replace(XmlElement(XmlName(fullscreen.toString())));
  }

  elementFound = true;
  if (fullscreen) {
    final uIViewControllerBasedStatusBarAppearance =
        dict.children.whereType<XmlElement>().firstWhere(
      (element) {
        return element.innerText == 'UIViewControllerBasedStatusBarAppearance';
      },
      orElse: () {
        final builder = XmlBuilder();
        builder.element(
          'key',
          nest: () {
            builder.text('UIViewControllerBasedStatusBarAppearance');
          },
        );
        dict.children.add(builder.buildFragment());
        dict.children.add(XmlElement(XmlName((!fullscreen).toString())));
        elementFound = false;
        return XmlElement(XmlName(''));
      },
    );

    if (elementFound) {
      final index =
          dict.children.indexOf(uIViewControllerBasedStatusBarAppearance);

      final uIViewControllerBasedStatusBarAppearanceValue = dict
          .children[index + 1].following
          .firstWhere((element) => element.nodeType == XmlNodeType.ELEMENT);
      uIViewControllerBasedStatusBarAppearanceValue
          .replace(XmlElement(XmlName('false')));
    }
  }

  file.writeAsStringSync(
    '${xmlDocument.toXmlString(pretty: true, indent: '	')}\n',
  );
}
