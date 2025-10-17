import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_native_splash/enums.dart';

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
      help: 'Flavor to remove the splash for.',
    );

  final parsedArgs = parser.parse(args);

  final helpArg = parsedArgs[ArgEnums.help.name];

  if (helpArg != null) {
    // ignore_for_file: avoid_print
    print(parser.usage);
    return;
  }

  removeSplash(
    path: parsedArgs[ArgEnums.path.name]?.toString(),
    flavor: parsedArgs[ArgEnums.flavor.name]?.toString(),
  );
}
