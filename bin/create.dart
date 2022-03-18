import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';

void main(List<String> args) {
  var parser = ArgParser();

  parser.addOption('path');
  parser.addOption('flavor');

  final parsedArgs = parser.parse(args);

  createSplash(path: parsedArgs['path'], flavor: parsedArgs['flavor']);
}
