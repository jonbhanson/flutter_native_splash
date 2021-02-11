part of flutter_native_splash_supported_platform;

// Image template
class _WebLaunchImageTemplate {
  final String fileName;
  final double divider;
  _WebLaunchImageTemplate({this.fileName, this.divider});
}

/// Create Android splash screen
Future<void> _createWebSplash({
  String imagePath,
  String darkImagePath,
  String color,
  String darkColor,
  String imageMode,
}) async {
  if (!File(_webIndex).existsSync()) {
    print('[Web] ' + _webIndex + ' not found.  Skipping Web.');
    return;
  }

  if (darkImagePath.isEmpty) darkImagePath = imagePath;
  await createWebImages(imagePath: imagePath, webSplashImages: [
    _WebLaunchImageTemplate(fileName: 'light-1x.png', divider: 3.0),
    _WebLaunchImageTemplate(fileName: 'light-2x.png', divider: 1.5),
    _WebLaunchImageTemplate(fileName: 'light-3x.png', divider: 1.0),
  ]);
  await createWebImages(imagePath: darkImagePath, webSplashImages: [
    _WebLaunchImageTemplate(fileName: 'dark-1x.png', divider: 3.0),
    _WebLaunchImageTemplate(fileName: 'dark-2x.png', divider: 1.5),
    _WebLaunchImageTemplate(fileName: 'dark-3x.png', divider: 1.0),
  ]);
  await createSplashCss(color: color, darkColor: darkColor);
  await updateIndex(imageMode: imageMode, showImages: imagePath.isNotEmpty);
}

void createWebImages(
    {String imagePath, List<_WebLaunchImageTemplate> webSplashImages}) async {
  if (imagePath.isEmpty) {
    for (var template in webSplashImages) {
      final file = File(_webSplashImagesFolder + template.fileName);
      if (file.existsSync()) file.deleteSync();
    }
  } else {
    final image = decodeImage(File(imagePath).readAsBytesSync());
    print('[Web] Creating images');
    for (var template in webSplashImages) {
      await _saveImageWeb(template: template, image: image);
    }
  }
}

dynamic _saveImageWeb({_WebLaunchImageTemplate template, Image image}) async {
  var newFile = await copyResize(
    image,
    width: image.width ~/ template.divider,
    height: image.height ~/ template.divider,
    interpolation: Interpolation.linear,
  );

  var file = await File(_webSplashImagesFolder + template.fileName)
      .create(recursive: true);
  await file.writeAsBytes(encodePng(newFile));
}

void createSplashCss({String color, String darkColor}) {
  print('[Web] Creating CSS');
  if (darkColor.isEmpty) darkColor = color;
  var cssContent = _webCss
      .replaceFirst('[LIGHTBACKGROUNDCOLOR]', '#' + color)
      .replaceFirst('[DARKBACKGROUNDCOLOR]', '#' + darkColor);
  File(_webFolder + _webRelativeStyleFile).writeAsStringSync(cssContent);
}

void updateIndex({String imageMode, bool showImages}) async {
  print('[Web] Updating index.html');
  final webIndex = File(_webIndex);
  var lines = webIndex.readAsLinesSync();

  var foundExistingStyleSheet = false;
  var headCloseTagLine = 0;
  var bodyCloseTagLine = 0;
  var existingPictureLine = 0;

  final styleSheetLink =
      '<link rel="stylesheet" type="text/css" href="splash/style.css">';
  for (var x = 0; x < lines.length; x++) {
    var line = lines[x];

    if (line.contains(styleSheetLink)) {
      foundExistingStyleSheet = true;
    } else if (line.contains('</head>')) {
      headCloseTagLine = x;
    } else if (line.contains('</body>')) {
      bodyCloseTagLine = x;
    } else if (line.contains('<picture id="splash">')) {
      existingPictureLine = x;
    }
  }

  if (!foundExistingStyleSheet) {
    lines[headCloseTagLine] = '  ' + styleSheetLink + '\n</head>';
  }

  if (existingPictureLine == 0) {
    if (showImages) {
      for (var x = _indexHtmlPicture.length - 1; x >= 0; x--) {
        lines[bodyCloseTagLine] =
            _indexHtmlPicture[x].replaceFirst('[IMAGEMODE]', imageMode) +
                '\n' +
                lines[bodyCloseTagLine];
      }
    }
  } else {
    if (showImages) {
      for (var x = 0; x < _indexHtmlPicture.length; x++) {
        lines[existingPictureLine + x] =
            _indexHtmlPicture[x].replaceFirst('[IMAGEMODE]', imageMode);
      }
    } else {
      lines.removeRange(
          existingPictureLine, existingPictureLine + _indexHtmlPicture.length);
    }
  }
  webIndex.writeAsStringSync(lines.join('\n'));
}
