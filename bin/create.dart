import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption('path', callback: (path) => {createSplash(path: path)});
  parser.parse(args);
}
