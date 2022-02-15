/// When your app is opened, there is a brief time while the native app loads
/// Flutter. By default, during this time, the native app displays a white
/// splash screen. This package automatically generates iOS, Android, and
/// Web-native code for customizing this native splash screen background color
/// and splash image. Supports dark mode, full screen, and platform-specific
/// options.
library flutter_native_splash;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/remove_splash.dart';

class FlutterNativeSplash {
  static void removeAfter(Function initializeFunction) {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    // Prevents app from closing splash screen, app layout will be build but not displayed.
    binding.deferFirstFrame();
    binding.addPostFrameCallback((_) async {
      BuildContext? context = binding.renderViewElement;
      if (context != null) {
        // Run any sync or awaited async function you want to wait for before showing app layout
        await initializeFunction.call(context);
      }

      // Closes splash screen, and show the app layout.
      binding.allowFirstFrame();
      if (kIsWeb) {
        removeSplashFromWeb();
      }
    });
  }

  static WidgetsBinding? _widgetsBinding;

  // Prevents app from closing splash screen, app layout will be build but not displayed.
  static void preserve({required WidgetsBinding widgetsBinding}) {
    _widgetsBinding = widgetsBinding;
    _widgetsBinding!.deferFirstFrame();
  }

  static void remove() {
    _widgetsBinding?.allowFirstFrame();
    _widgetsBinding = null;
    if (kIsWeb) {
      try {
        removeSplashFromWeb();
      } catch (e) {
        throw Exception(e.toString() +
            '\nDid you forget to run '
                '"flutter pub run flutter_native_splash:create"?');
      }
    }
  }
}
