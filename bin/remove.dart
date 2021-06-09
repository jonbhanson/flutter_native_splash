import 'package:args/args.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'
    as flutter_native_splash;

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption('path',
      callback: (path) => {flutter_native_splash.removeSplash(path)});
  parser.parse(args);
}
