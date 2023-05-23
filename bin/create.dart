import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';

void main(List<String> args) {
  final parser = ArgParser();

  parser.addOption('path');
  parser.addOption('flavor');
  parser.addOption('flavors');

  final parsedArgs = parser.parse(args);

  if (parsedArgs['flavor'] != null && parsedArgs['flavors'] != null) {
    throw Exception('Cannot use both flavor and flavors arguments');
  }

  if (parsedArgs['flavor'] != null) {
    createSplash(
      path: parsedArgs['path']?.toString(),
      flavor: parsedArgs['flavor']?.toString(),
    );
  } else if (parsedArgs['flavors'] != null) {
    final flavors = parsedArgs['flavors']?.toString().split(',');
    for (final flavor in flavors!) {
      createSplash(
        path: parsedArgs['path']?.toString(),
        flavor: flavor,
      );
    }
  } else {
    createSplash(
      path: parsedArgs['path']?.toString(),
      flavor: null,
    );
  }
}
