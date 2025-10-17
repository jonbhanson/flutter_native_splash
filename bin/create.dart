import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_native_splash/enums.dart';
import 'package:flutter_native_splash/helper_utils.dart';

void main(List<String> args) {
  final parser = ArgParser();

  parser
    ..addFlag(
      ArgEnums.help.name,
      abbr: ArgEnums.help.abbr,
      help: 'Show help',
    )
    ..addOption(
      ArgEnums.path.name,
      abbr: ArgEnums.path.abbr,
      help:
          'Path to the flutter project, if the project is not in it\'s default location.',
    )
    ..addOption(
      ArgEnums.flavor.name,
      abbr: ArgEnums.flavor.abbr,
      help:
          'Flavor to create the splash for. The flavor must match the pattern flutter_native_splash-*.yaml (where * is the flavor name).',
    )
    ..addOption(
      ArgEnums.flavors.name,
      abbr: ArgEnums.flavors.abbr,
      help:
          'Comma separated list of flavors to create the splash screens for. Match the pattern flutter_native_splash-*.yaml (where * is the flavor name).',
    )
    ..addFlag(
      ArgEnums.allFlavors.name,
      abbr: ArgEnums.allFlavors.abbr,
      help:
          'Create the splash screens for all flavors that match the pattern flutter_native_splash-*.yaml (where * is the flavor name).',
    );

  final parsedArgs = parser.parse(args);

  final helpArg = parsedArgs[ArgEnums.help.name] as bool?;

  if (helpArg == true) {
    // ignore_for_file: avoid_print
    print(parser.usage);
    return;
  }

  final pathArg = parsedArgs[ArgEnums.path.name]?.toString();
  final flavorArg = parsedArgs[ArgEnums.flavor.name]?.toString();
  final flavorsArg = parsedArgs[ArgEnums.flavors.name]?.toString();
  final allFlavorsArg = parsedArgs[ArgEnums.allFlavors.name] as bool?;

  // Validate the flavor arguments
  HelperUtils.validateFlavorArgs(
    flavorArg: flavorArg,
    flavorsArg: flavorsArg,
    allFlavorsArg: allFlavorsArg,
  );

  if (flavorArg != null) {
    createSplash(
      path: pathArg,
      flavor: flavorArg,
    );
  } else if (flavorsArg != null) {
    for (final flavor in flavorsArg.split(',')) {
      createSplash(
        path: pathArg,
        flavor: flavor,
      );
    }
  } else if (allFlavorsArg == true) {
    // Find all flavor configurations in current project directory
    final flavors = Directory.current
        .listSync()
        .whereType<File>()
        .map((entity) => entity.path.split(Platform.pathSeparator).last)
        .where(HelperUtils.isValidFlavorConfigFileName)
        .map(HelperUtils.getFlavorNameFromFileName)
        .toList();

    print('Found ${flavors.length} flavor configurations: $flavors');

    for (final flavor in flavors) {
      createSplash(
        path: pathArg,
        flavor: flavor,
      );
    }
  } else {
    createSplash(
      path: pathArg,
      flavor: null,
    );
  }
}
