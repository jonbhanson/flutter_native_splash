import 'package:flutter_native_splash/enums.dart';

class HelperUtils {
  const HelperUtils._();

  /// Checks if a given filename matches the flutter native splash flavor config pattern
  /// The pattern is: flutter_native_splash-*.yaml where * is the flavor name
  ///
  /// Returns true if the filename matches the pattern, false otherwise
  static bool isValidFlavorConfigFileName(String fileName) {
    return RegExp(r'^flutter_native_splash-[^-]+\.yaml$').hasMatch(fileName);
  }

  /// Extracts the flavor name from a valid flavor config filename
  ///
  /// Throws an exception if the filename is not a valid flavor config filename
  static String getFlavorNameFromFileName(String fileName) {
    final flavorMatch =
        RegExp(r'^flutter_native_splash-(.+)\.yaml$').firstMatch(fileName);

    final flavorName = flavorMatch?.group(1);

    if (flavorName == null) {
      throw Exception('Invalid flavor config filename: $fileName');
    }

    return flavorName;
  }

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
