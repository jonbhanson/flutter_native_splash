// If the current platform is unsupported, throw an error.

void tryCreateSplashByConfig(Map<String, dynamic> config) async {
  throw UnsupportedError(
      'This package requires dart:io, which is unsupported by this platform.');
}

void tryCreateSplash() async {
  throw UnsupportedError(
      'This package requires dart:io, which is unsupported by this platform.');
}
