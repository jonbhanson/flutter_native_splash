import 'package:flutter_native_splash/helper_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HelperUtils.isValidFlavorConfigFileName', () {
    test('should return true for valid flavor config filenames', () {
      expect(
        HelperUtils.isValidFlavorConfigFileName(
            'flutter_native_splash-dev.yaml'),
        isTrue,
      );
      expect(
        HelperUtils.isValidFlavorConfigFileName(
            'flutter_native_splash-prod.yaml'),
        isTrue,
      );
      expect(
        HelperUtils.isValidFlavorConfigFileName(
            'flutter_native_splash-staging.yaml'),
        isTrue,
      );
    });

    test('should return false for invalid flavor config filenames', () {
      expect(
        HelperUtils.isValidFlavorConfigFileName('flutter_native_splash.yaml'),
        isFalse,
      );
      expect(
        HelperUtils.isValidFlavorConfigFileName('flutter_native_splash-.yaml'),
        isFalse,
      );
      expect(
        HelperUtils.isValidFlavorConfigFileName(
            'flutter_native_splash-dev.yml'),
        isFalse,
      );
      expect(
        HelperUtils.isValidFlavorConfigFileName('other-config.yaml'),
        isFalse,
      );
      expect(
        HelperUtils.isValidFlavorConfigFileName('random.txt'),
        isFalse,
      );
    });
  });

  group('HelperUtils.getFlavorNameFromFileName', () {
    test('should return the flavor name from a valid flavor config filename',
        () {
      expect(
        HelperUtils.getFlavorNameFromFileName('flutter_native_splash-dev.yaml'),
        'dev',
      );
      expect(
        HelperUtils.getFlavorNameFromFileName(
          'flutter_native_splash-prod.yaml',
        ),
        'prod',
      );
      expect(
        HelperUtils.getFlavorNameFromFileName(
          'flutter_native_splash-staging-flavor.yaml',
        ),
        'staging-flavor',
      );
    });

    test(
        'should throw an exception if the filename is not a valid flavor config filename',
        () {
      expect(
        () => HelperUtils.getFlavorNameFromFileName(
          'flutter_native_splash.yaml',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid flavor config filename'),
          ),
        ),
      );
    });
  });

  group('Flavor arguments validation', () {
    test('throws when flavor and flavors are used together', () {
      expect(
        () => HelperUtils.validateFlavorArgs(
          flavorArg: 'dev',
          flavorsArg: 'dev,prod',
          allFlavorsArg: false,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot use multiple flavor options together'),
          ),
        ),
      );
    });

    test('throws when flavor and allFlavors are used together', () {
      expect(
        () => HelperUtils.validateFlavorArgs(
          flavorArg: 'dev',
          flavorsArg: null,
          allFlavorsArg: true,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot use multiple flavor options together'),
          ),
        ),
      );
    });

    test('throws when flavors and allFlavors are used together', () {
      expect(
        () => HelperUtils.validateFlavorArgs(
          flavorArg: null,
          flavorsArg: 'dev,prod',
          allFlavorsArg: true,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot use multiple flavor options together'),
          ),
        ),
      );
    });

    test('does not throw with single flavor option', () {
      expect(
        () => HelperUtils.validateFlavorArgs(
          flavorArg: 'dev',
          flavorsArg: null,
          allFlavorsArg: false,
        ),
        returnsNormally,
      );
    });
  });
}
