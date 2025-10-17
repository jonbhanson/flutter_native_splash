part of 'cli_commands.dart';

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
    // ignore_for_file: avoid_print
    print('[Web] $_webIndex not found.  Skipping Web.');
    return;
  }

  // Config for removing splash screen:
  if (imagePath == null &&
      darkImagePath == null &&
      color == "ffffff" &&
      darkColor == "000000" &&
      brandingImagePath == null &&
      brandingDarkImagePath == null &&
      backgroundImage == null &&
      darkBackgroundImage == null) {
    Directory splashFolder = Directory(_webSplashFolder);
    if (splashFolder.existsSync()) splashFolder.deleteSync(recursive: true);
    final webIndex = File(_webIndex);
    final document = html_parser.parse(webIndex.readAsStringSync());
    // Remove items that may have been added to index.html:
    document
        .querySelector(
          'link[rel="stylesheet"][type="text/css"][href="splash/style.css"]',
        )
        ?.remove();
    document
        .querySelector(
          'meta[content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"][name="viewport"]',
        )
        ?.remove();
    document.querySelector('script[src="splash/splash.js"]')?.remove();
    document.querySelector('picture#splash')?.remove();
    document.querySelector('picture#splash-branding')?.remove();
    document.querySelector('div#splash')?.remove();
    webIndex.writeAsStringSync(document.outerHtml);
    return;
  }

  darkImagePath ??= imagePath;
  final imageExtension = (imagePath?.endsWith('.gif') ?? false) ? 'gif' : 'png';

  _createWebImages(
    imagePath: imagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(
        fileName: 'light-1x.$imageExtension',
        pixelDensity: 1,
      ),
      _WebLaunchImageTemplate(
        fileName: 'light-2x.$imageExtension',
        pixelDensity: 2,
      ),
      _WebLaunchImageTemplate(
        fileName: 'light-3x.$imageExtension',
        pixelDensity: 3,
      ),
      _WebLaunchImageTemplate(
        fileName: 'light-4x.$imageExtension',
        pixelDensity: 4,
      ),
    ],
  );
  final darkImageExtension =
      (darkImagePath?.endsWith('.gif') ?? false) ? 'gif' : 'png';
  _createWebImages(
    imagePath: darkImagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(
        fileName: 'dark-1x.$darkImageExtension',
        pixelDensity: 1,
      ),
      _WebLaunchImageTemplate(
        fileName: 'dark-2x.$darkImageExtension',
        pixelDensity: 2,
      ),
      _WebLaunchImageTemplate(
        fileName: 'dark-3x.$darkImageExtension',
        pixelDensity: 3,
      ),
      _WebLaunchImageTemplate(
        fileName: 'dark-4x.$darkImageExtension',
        pixelDensity: 4,
      ),
    ],
  );

  brandingDarkImagePath ??= brandingImagePath;
  final brandingExtension =
      (brandingImagePath?.endsWith('.gif') ?? false) ? 'gif' : 'png';

  _createWebImages(
    imagePath: brandingImagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(
        fileName: 'branding-1x.$brandingExtension',
        pixelDensity: 1,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-2x.$brandingExtension',
        pixelDensity: 2,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-3x.$brandingExtension',
        pixelDensity: 3,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-4x.$brandingExtension',
        pixelDensity: 4,
      ),
    ],
  );

  final darkBrandingExtension =
      (brandingDarkImagePath?.endsWith('.gif') ?? false) ? 'gif' : 'png';
  _createWebImages(
    imagePath: brandingDarkImagePath,
    webSplashImages: [
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-1x.$darkBrandingExtension',
        pixelDensity: 1,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-2x.$darkBrandingExtension',
        pixelDensity: 2,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-3x.$darkBrandingExtension',
        pixelDensity: 3,
      ),
      _WebLaunchImageTemplate(
        fileName: 'branding-dark-4x.$darkBrandingExtension',
        pixelDensity: 4,
      ),
    ],
  );

  _createBackgroundImages(
    backgroundImage: backgroundImage,
    darkBackgroundImage: darkBackgroundImage,
  );
  _createSplashCss(
    color: color,
    darkColor: darkColor,
    darkBackgroundImage: darkBackgroundImage,
    backgroundImage: backgroundImage,
    hasDarkImage: darkBackgroundImage != null,
  );
  _createSplashJs();
  _updateHtml(
    imageMode: imageMode,
    imagePath: imagePath,
    brandingMode: brandingMode,
    brandingImagePath: brandingImagePath,
  );
}

void _createBackgroundImages({
  required String? backgroundImage,
  required String? darkBackgroundImage,
}) {
  print('[Web] Creating background images');

  final bgExtension =
      (backgroundImage?.endsWith('.gif') ?? false) ? 'gif' : 'png';
  _createBackgroundImage(
    backgroundImage: backgroundImage,
    fileName: "light-background.$bgExtension",
  );

  final darkBgExtension =
      (darkBackgroundImage?.endsWith('.gif') ?? false) ? 'gif' : 'png';
  _createBackgroundImage(
    backgroundImage: darkBackgroundImage,
    fileName: "dark-background.$darkBgExtension",
  );
}

void _createBackgroundImage({
  required String? backgroundImage,
  required String fileName,
}) {
  final backgroundDestination = '$_webSplashImagesFolder$fileName';
  if (backgroundImage == null) {
    final file = File(backgroundDestination);
    if (file.existsSync()) file.deleteSync();
  } else {
    createBackgroundImage(
      imageDestination: backgroundDestination,
      imageSource: backgroundImage,
    );
  }
}

void _createWebImages({
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
    interpolation: Interpolation.average,
  );

  final file = File(_webSplashImagesFolder + template.fileName);
  file.createSync(recursive: true);
  file.writeAsBytesSync(
    (template.fileName.endsWith('.gif') ? encodeGif : encodePng)(newFile),
  );
}

void _createSplashCss({
  required String? color,
  required String? darkColor,
  required String? backgroundImage,
  required String? darkBackgroundImage,
  required bool hasDarkImage,
}) {
  print('[Web] Creating CSS');
  color ??= 'ffffff';
  var cssContent = _webCss.replaceFirst('[LIGHTBACKGROUNDCOLOR]', '#$color');
  if (darkColor != null || darkBackgroundImage != null || hasDarkImage) {
    darkColor ??= '000000';
    cssContent += _webCssDark.replaceFirst(
      '[DARKBACKGROUNDCOLOR]',
      '#$darkColor',
    );
  }

  if (backgroundImage == null) {
    cssContent = cssContent.replaceFirst('  [LIGHTBACKGROUNDIMAGE]\n', '');
  } else {
    final bgExtension = backgroundImage.endsWith('.gif') ? 'gif' : 'png';

    cssContent = cssContent.replaceFirst(
      '[LIGHTBACKGROUNDIMAGE]',
      'background-image: url("splash/img/light-background.$bgExtension");',
    );
  }

  if (darkBackgroundImage == null) {
    cssContent = cssContent.replaceFirst('    [DARKBACKGROUNDIMAGE]\n', '');
  } else {
    final darkBgExtension =
        darkBackgroundImage.endsWith('.gif') ? 'gif' : 'png';

    cssContent = cssContent.replaceFirst(
      '[DARKBACKGROUNDIMAGE]',
      'background-image: url("splash/img/dark-background.$darkBgExtension");',
    );
  }

  cssContent += '  </style>\n';

  // Add css as an inline style in head tag
  final webIndex = File(_webIndex);
  final document = html_parser.parse(webIndex.readAsStringSync());

  // Update splash css style tag
  document.head
    ?..querySelector('style#splash-screen-style')?.remove()
    ..append(
      html_parser.parseFragment(cssContent, container: ''),
    );

  // Write the updated index.html
  webIndex.writeAsStringSync(document.outerHtml);
}

void _createSplashJs() {
  // Add js as an inline script in head tag
  final webIndex = File(_webIndex);
  final document = html_parser.parse(webIndex.readAsStringSync());

  // Update splash js script tag
  document.head
    ?..querySelector('script#splash-screen-script')?.remove()
    ..append(
      html_parser.parseFragment(_webJS, container: ''),
    );

  // Write the updated index.html
  webIndex.writeAsStringSync(document.outerHtml);
}

void _updateHtml({
  required String imageMode,
  required String? imagePath,
  required String brandingMode,
  required String? brandingImagePath,
}) {
  print('[Web] Updating index.html');
  final webIndex = File(_webIndex);
  final document = html_parser.parse(webIndex.readAsStringSync());

  // Remove previously used style sheet (migrating to inline style)
  document
      .querySelector(
        'link[rel="stylesheet"][type="text/css"][href="splash/style.css"]',
      )
      ?.remove();

  // Add meta viewport if it doesn't exist
  document.querySelector(
        'meta[content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"][name="viewport"]',
      ) ??
      document.head?.append(
        html_parser.parseFragment(
          '  <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport">\n',
          container: '',
        ),
      );

  // Remove previously used src script tag (migrating to inline script)
  document
      .querySelector(
        'script[src="splash/splash.js"]',
      )
      ?.remove();

  // Update splash image
  document.querySelector('picture#splash')?.remove();
  document.querySelector('div#splash')?.remove();
  if (imagePath != null) {
    document.body?.insertBefore(
      html_parser.parseFragment(
        '\n${_indexHtmlPicture.replaceAll(
              '[IMAGEMODE]',
              imageMode,
            ).replaceAll(
              '[IMAGEEXTENSION]',
              imagePath.endsWith('.gif') ? 'gif' : 'png',
            )}',
        container: '',
      ),
      document.body?.firstChild,
    );
  }

  // Update branding image
  document.querySelector('picture#splash-branding')?.remove();
  if (brandingImagePath != null) {
    document.body?.insertBefore(
      html_parser.parseFragment(
        '\n${_indexHtmlBrandingPicture.replaceAll(
              '[BRANDINGMODE]',
              brandingMode,
            ).replaceAll(
              '[BRANDINGEXTENSION]',
              brandingImagePath.endsWith('.gif') ? 'gif' : 'png',
            )}',
        container: '',
      ),
      document.body?.firstChild,
    );
  }

  // Write the updated index.html
  webIndex.writeAsStringSync(document.outerHtml);
}
