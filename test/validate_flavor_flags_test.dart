import 'package:flutter_native_splash/helper_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
