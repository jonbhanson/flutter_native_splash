import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';

void main(List<String> args) {
  final parser = ArgParser();

  parser.addOption('path');
  parser.addOption('flavor');
  parser.addOption('module');

  final parsedArgs = parser.parse(args);

  removeSplash(
    path: parsedArgs['path']?.toString(),
    flavor: parsedArgs['flavor']?.toString(),
    module: parsedArgs['module']?.toString(),
  );
}
