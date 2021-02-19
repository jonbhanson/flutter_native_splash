/// ## If the current platform is unsupported, throw an error.
///
/// Creating images necessary for the splash screens requires the io.dart package, which
/// unfortunately does not have support for JS.  Because pub.dev docks pub points for
/// packages not being cross-platform, it is necessary to use
/// [conditional imports](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files)
/// to avoid losing pub points.  This library is included when the package is loaded on
/// an unsupported platform, and its only purpose is to trigger an exception.
library flutter_native_splash_unsupported_platform;

/// Function that will be called on unsupported platforms, triggering exception.
void tryCreateSplashByConfig(Map<String, dynamic> config) async {
  throw UnsupportedError(
      'This package requires dart:io, which is unsupported by this platform.');
}

/// Function that will be called on unsupported platforms, triggering exception.
Future<void> tryCreateSplash() async {
  throw UnsupportedError(
      'This package requires dart:io, which is unsupported by this platform.');
}

/// Function that will be called on unsupported platforms, triggering exception.
Future<void> tryRemoveSplash() async {
  throw UnsupportedError(
      'This package requires dart:io, which is unsupported by this platform.');
}
