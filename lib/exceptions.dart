class NoConfigFoundException implements Exception {
  const NoConfigFoundException([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'NoConfigFoundException\n'
        '$message';
  }
}

class InvalidConfigException implements Exception {
  const InvalidConfigException([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'InvalidConfigException\n'
        '$message';
  }
}

class NoImageFileFoundException implements Exception {
  const NoImageFileFoundException([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'NoImageFileFoundException\n'
        '$message';
  }
}

class CantFindMainActivityPath implements Exception {
  const CantFindMainActivityPath([this.message]);
  final String message;

  @override
  String toString() {
    return '*** ERROR [flutter_native_splash] ***\n'
        'CantFindMainActivityPath\n'
        '$message';
  }
}
