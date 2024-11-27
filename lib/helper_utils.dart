import 'package:flutter_native_splash/enums.dart';

class HelperUtils {
  const HelperUtils._();

  /// Validate the flavor arguments
  ///
  /// Throws an exception if the arguments are invalid.
  static void validateFlavorArgs({
    required String? flavorArg,
    required String? flavorsArg,
    required bool? allFlavorsArg,
  }) {
    if ((flavorArg != null && flavorsArg != null) ||
        (flavorArg != null && allFlavorsArg == true) ||
        (flavorsArg != null && allFlavorsArg == true)) {
      throw Exception(
        'Cannot use multiple flavor options together. Please use only one of: --${ArgEnums.flavor.name}, --${ArgEnums.flavors.name}, or --${ArgEnums.allFlavors.name}.',
      );
    }
  }
}
