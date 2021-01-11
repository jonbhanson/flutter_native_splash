part of flutter_native_splash_supported_platform;

class _NoConfigFoundException implements Exception {
  const _NoConfigFoundException([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'NoConfigFoundException\n'
        '$message';
  }
}

class _InvalidConfigException implements Exception {
  const _InvalidConfigException([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'InvalidConfigException\n'
        '$message';
  }
}

class _NoImageFileFoundException implements Exception {
  const _NoImageFileFoundException([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'NoImageFileFoundException\n'
        '$message';
  }
}

class _CantFindMainActivityPath implements Exception {
  const _CantFindMainActivityPath([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'CantFindMainActivityPath\n'
        '$message';
  }
}

class _CantFindAppDelegatePath implements Exception {
  const _CantFindAppDelegatePath([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'CantFindAppDelegatePath\n'
        '$message';
  }
}

class _InvalidNativeFile implements Exception {
  const _InvalidNativeFile([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'InvalidNativeFile\n'
        '$message';
  }
}

class _LaunchScreenStoryboardModified implements Exception {
  const _LaunchScreenStoryboardModified([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'LaunchScreenStoryboardModified\n'
        '$message';
  }
}
