part of flutter_native_splash_cli;

// Image template
class _WebLaunchImageTemplate {
  final String fileName;
  final double pixelDensity;
  _WebLaunchImageTemplate({required this.fileName, required this.pixelDensity});
}

/// Create Web splash screen
void _createWebSplash({
  required String? imagePath,
  required String? darkImagePath,
  required String? color,
  required String? darkColor,
  required String? brandingImagePath,
  required String? brandingDarkImagePath,
  required String imageMode,
  required String brandingMode,
  required String? backgroundImage,
  required String? darkBackgroundImage,
}) {
  if (!File(_webIndex).existsSync()) {
    print('[Web] $_webIndex not found.  Skipping Web.');
    return;
  }

  darkImagePath ??= imagePath;
  createWebImages(
    imagePath: imagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(fileName: 'light-1x.png', pixelDensity: 1),
      _WebLaunchImageTemplate(fileName: 'light-2x.png', pixelDensity: 2),
      _WebLaunchImageTemplate(fileName: 'light-3x.png', pixelDensity: 3),
      _WebLaunchImageTemplate(fileName: 'light-4x.png', pixelDensity: 4),
    ],
  );
  createWebImages(
    imagePath: darkImagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(fileName: 'dark-1x.png', pixelDensity: 1),
      _WebLaunchImageTemplate(fileName: 'dark-2x.png', pixelDensity: 2),
      _WebLaunchImageTemplate(fileName: 'dark-3x.png', pixelDensity: 3),
      _WebLaunchImageTemplate(fileName: 'dark-4x.png', pixelDensity: 4),
    ],
  );

  brandingDarkImagePath ??= brandingImagePath;
  createWebImages(
    imagePath: brandingImagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(fileName: 'branding-1x.png', pixelDensity: 1),
      _WebLaunchImageTemplate(fileName: 'branding-2x.png', pixelDensity: 2),
      _WebLaunchImageTemplate(fileName: 'branding-3x.png', pixelDensity: 3),
      _WebLaunchImageTemplate(fileName: 'branding-4x.png', pixelDensity: 4),
    ],
  );
  createWebImages(
    imagePath: brandingDarkImagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-1x.png',
        pixelDensity: 1,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-2x.png',
        pixelDensity: 2,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-3x.png',
        pixelDensity: 3,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-4x.png',
        pixelDensity: 4,
      ),
    ],
  );

  createBackgroundImages(
    backgroundImage: backgroundImage,
    darkBackgroundImage: darkBackgroundImage,
  );
  _createSplashCss(
    color: color,
    darkColor: darkColor,
    darkBackgroundImage: darkBackgroundImage,
    backgroundImage: backgroundImage,
  );
  _createSplashJs();
  updateIndex(
    imageMode: imageMode,
    imagePath: imagePath,
    brandingMode: brandingMode,
    brandingImagePath: brandingImagePath,
  );
}

void createBackgroundImages({
  required String? backgroundImage,
  required String? darkBackgroundImage,
}) {
  const backgroundDestination = '${_webSplashImagesFolder}light-background.png';
  if (backgroundImage == null) {
    final file = File(backgroundDestination);
    if (file.existsSync()) file.deleteSync();
  } else {
    // Copy will not work if the directory does not exist, so createSync
    // will ensure that the directory exists.
    File(backgroundDestination).createSync(recursive: true);
    File(backgroundImage).copySync(backgroundDestination);
  }

  const darkBackgroundDestination =
      '${_webSplashImagesFolder}dark-background.png';
  if (darkBackgroundImage == null) {
    final file = File(darkBackgroundDestination);
    if (file.existsSync()) file.deleteSync();
  } else {
    // Copy will not work if the directory does not exist, so createSync
    // will ensure that the directory exists.
    File(darkBackgroundDestination).createSync(recursive: true);
    File(darkBackgroundImage).copySync(darkBackgroundDestination);
  }
}

void createWebImages({
  required String? imagePath,
  required List<_WebLaunchImageTemplate> webSplashImages,
}) {
  if (imagePath == null) {
    for (final template in webSplashImages) {
      final file = File(_webSplashImagesFolder + template.fileName);
      if (file.existsSync()) file.deleteSync();
    }
  } else {
    final image = decodeImage(File(imagePath).readAsBytesSync());
    if (image == null) {
      print('$imagePath could not be read');
      exit(1);
    }
    print('[Web] Creating images');
    for (final template in webSplashImages) {
      _saveImageWeb(template: template, image: image);
    }
  }
}

void _saveImageWeb({
  required _WebLaunchImageTemplate template,
  required Image image,
}) {
  final newFile = copyResize(
    image,
    width: image.width * template.pixelDensity ~/ 4,
    height: image.height * template.pixelDensity ~/ 4,
    interpolation: Interpolation.linear,
  );

  final file = File(_webSplashImagesFolder + template.fileName);
  file.createSync(recursive: true);
  file.writeAsBytesSync(encodePng(newFile));
}

void _createSplashCss({
  required String? color,
  required String? darkColor,
  required String? backgroundImage,
  required String? darkBackgroundImage,
}) {
  print('[Web] Creating CSS');
  color ??= '000000';
  darkColor ??= color;
  var cssContent = _webCss
      .replaceFirst('[LIGHTBACKGROUNDCOLOR]', '#$color')
      .replaceFirst('[DARKBACKGROUNDCOLOR]', '#$darkColor');

  if (backgroundImage == null) {
    cssContent = cssContent.replaceFirst('[LIGHTBACKGROUNDIMAGE]', '');
  } else {
    cssContent = cssContent.replaceFirst(
      '[LIGHTBACKGROUNDIMAGE]',
      'background-image: url("img/light-background.png");',
    );
  }

  if (backgroundImage == null) {
    cssContent = cssContent.replaceFirst('[DARKBACKGROUNDIMAGE]', '');
  } else {
    cssContent = cssContent.replaceFirst(
      '[DARKBACKGROUNDIMAGE]',
      'background-image: url("img/dark-background.png");',
    );
  }

  final file = File(_webFolder + _webRelativeStyleFile);
  file.createSync(recursive: true);
  file.writeAsStringSync(cssContent);
}

void _createSplashJs() {
  final file = File(_webFolder + _webRelativeJSFile);
  file.createSync(recursive: true);
  file.writeAsStringSync(_webJS);
}

void updateIndex({
  required String imageMode,
  required String? imagePath,
  required String brandingMode,
  required String? brandingImagePath,
}) {
  print('[Web] Updating index.html');
  final webIndex = File(_webIndex);
  final lines = webIndex.readAsLinesSync();

  var foundExistingStyleSheet = false;
  bool foundExistingMetaViewport = false;
  bool foundExistingJs = false;
  var headCloseTagLine = 0;
  var bodyOpenTagLine = 0;
  var existingPictureLine = 0;
  var existingBrandingPictureLine = 0;

  const styleSheetLink =
      '<link rel="stylesheet" type="text/css" href="splash/style.css">';
  const metaViewport =
      '<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport"/>';
  const jsLink = '<script src="splash/splash.js"></script>';
  for (var x = 0; x < lines.length; x++) {
    final line = lines[x];

    if (line.contains(styleSheetLink)) {
      foundExistingStyleSheet = true;
    }
    if (line.contains(metaViewport)) {
      foundExistingMetaViewport = true;
    }
    if (line.contains(jsLink)) {
      foundExistingJs = true;
    }

    if (line.contains('</head>')) {
      headCloseTagLine = x;
    } else if (line.contains('<body')) {
      bodyOpenTagLine = x;
    } else if (line.contains('<picture id="splash">')) {
      existingPictureLine = x;
    } else if (line.contains('<picture id="splash-branding">')) {
      existingBrandingPictureLine = x;
    }
  }

  if (!foundExistingStyleSheet) {
    lines[headCloseTagLine] = '  $styleSheetLink\n${lines[headCloseTagLine]}';
  }
  if (!foundExistingMetaViewport) {
    lines[headCloseTagLine] = '  $metaViewport\n${lines[headCloseTagLine]}';
  }

  if (!foundExistingJs) {
    lines[headCloseTagLine] = '  $jsLink\n${lines[headCloseTagLine]}';
  }

  if (existingPictureLine == 0) {
    if (imagePath != null) {
      for (var x = _indexHtmlPicture.length - 1; x >= 0; x--) {
        lines[bodyOpenTagLine + 1] =
            '${_indexHtmlPicture[x].replaceFirst('[IMAGEMODE]', imageMode)}\n${lines[bodyOpenTagLine + 1]}';
      }
    }
  } else {
    if (imagePath != null) {
      for (var x = 0; x < _indexHtmlPicture.length; x++) {
        lines[existingPictureLine + x] =
            _indexHtmlPicture[x].replaceFirst('[IMAGEMODE]', imageMode);
      }
    } else {
      lines.removeRange(
        existingPictureLine,
        existingPictureLine + _indexHtmlPicture.length,
      );
    }
  }
  if (existingBrandingPictureLine == 0) {
    if (brandingImagePath != null) {
      for (var x = _indexHtmlBrandingPicture.length - 1; x >= 0; x--) {
        lines[bodyOpenTagLine + 1] =
            '${_indexHtmlBrandingPicture[x].replaceFirst('[BRANDINGMODE]', brandingMode)}\n${lines[bodyOpenTagLine + 1]}';
      }
    }
  } else {
    if (brandingImagePath != null) {
      for (var x = 0; x < _indexHtmlBrandingPicture.length; x++) {
        lines[existingBrandingPictureLine + x] = _indexHtmlBrandingPicture[x]
            .replaceFirst('[BRANDINGMODE]', brandingMode);
      }
    } else {
      lines.removeRange(
        existingBrandingPictureLine,
        existingBrandingPictureLine + _indexHtmlBrandingPicture.length,
      );
    }
  }
  webIndex.writeAsStringSync('${lines.join('\n')}\n');
}
