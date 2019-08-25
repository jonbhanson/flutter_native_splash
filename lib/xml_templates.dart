const String colorsXml = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_color">#2196F3</color>
</resources>
''';

const String launchBackgroundItemXml = '''
    <item>
        <bitmap android:gravity="center" android:src="@drawable/splash" />
    </item>
''';

const String launchBackgroundXml = '''
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_color" />

  $launchBackgroundItemXml
</layer-list>
''';

const String stylesItemXml = '''
        <item name="android:windowFullscreen">true</item>
''';

const String stylesXml = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    $stylesItemXml
    </style>
</resources>
''';

const String mainActivityLines1 = '''
import android.view.ViewTreeObserver;
import android.view.WindowManager;
''';

const String mainActivityLines2 = '''
    boolean flutter_native_splash = true;
    getWindow().setStatusBarColor(0x00000000);
''';

const String mainActivityLines3 = '''
    ViewTreeObserver vto = getFlutterView().getViewTreeObserver();
    vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
      @Override
      public void onGlobalLayout() {
        getFlutterView().getViewTreeObserver().removeOnGlobalLayoutListener(this);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
      }
    });
''';
