import 'package:args/args.dart';
import 'package:flutter_native_splash/cli_commands.dart';

void main(List<String> args) {
  final parser = ArgParser();
  parser.addOption('path', callback: (path) => {removeSplash(path: path)});
  parser.parse(args);
}
