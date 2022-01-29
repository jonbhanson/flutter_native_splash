library flutter_native_splash;

import 'package:flutter/widgets.dart';

class FlutterNativeSplash {
  static void removeAfter(Function initializeFunction) {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    // Prevents app from closing splash screen, app layout will be build but not displayed.
    binding.deferFirstFrame();
    binding.addPostFrameCallback((_) async {
      BuildContext? context = binding.renderViewElement;
      if (context != null) {
        // Run any sync or awaited async function you want to wait for before showing app layout
        await initializeFunction.call();
      }

      // Closes splash screen, and show the app layout.
      binding.allowFirstFrame();
    });
  }
}
