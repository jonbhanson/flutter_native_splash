/// ## Flutter Native Splash
///
/// This is the main entry point for the Flutter Native Splash package.
library flutter_native_splash;

/*
 pub.dev will give lower pub points for not supporting multiple platforms.
 Since create_splash makes use of dart:io which does not support JS,
 only import create_splash on platforms that support io.  For other platforms,
 throw an unsupported exception.
 */
import 'unsupported_platform.dart' // Stub implementation
    if (dart.library.io) 'supported_platform.dart'; // dart:io implementation

/// Create splash screens for Android and iOS
Future<void> createSplash() async {
  await tryCreateSplash();
}

/// Create splash screens for Android and iOS based on a config argument
Future<void> createSplashByConfig(Map<String, dynamic> config) async {
  tryCreateSplashByConfig(config);
}
