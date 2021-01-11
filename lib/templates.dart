part of flutter_native_splash_supported_platform;

// Android-related templates
const String _androidColorsXml = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_color">#2196F3</color>
</resources>
''';

const String _androidLaunchBackgroundItemXml = '''
    <item>
        <bitmap android:gravity="center" android:src="@drawable/splash" />
    </item>
''';

const String _androidLaunchBackgroundXml = '''
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_color" />

  $_androidLaunchBackgroundItemXml
</layer-list>
''';

const String _androidLaunchBackgroundItemXmlFill = '''
    <item>
        <bitmap android:gravity="fill" android:src="@drawable/splash" />
    </item>
''';

const String _androidLaunchBackgroundXmlFill = '''
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_color" />

  $_androidLaunchBackgroundItemXmlFill
</layer-list>
''';

const String _androidStylesItemXml = '''
        <item name="android:windowFullscreen">true</item>
''';

const String _androidStylesXml = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    $_androidStylesItemXml
    </style>
</resources>
''';

const String _androidMainActivityJavaImportLines1 = 'import android.os.Build;';
const String _androidMainActivityJavaImportLines2 =
    'import android.view.ViewTreeObserver;';
const String _androidMainActivityJavaImportLines3 =
    'import android.view.WindowManager;';

const String _androidMainActivityJavaLines2WithStatusBar = '''
    boolean flutter_native_splash = true;
    int originalStatusBarColor = 0;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        originalStatusBarColor = getWindow().getStatusBarColor();
        getWindow().setStatusBarColor({{{primaryColorDark}}});
    }
    int originalStatusBarColorFinal = originalStatusBarColor;
''';

const String _androidMainActivityJavaLines3 = '''
    ViewTreeObserver vto = getFlutterView().getViewTreeObserver();
    vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
      @Override
      public void onGlobalLayout() {
        getFlutterView().getViewTreeObserver().removeOnGlobalLayoutListener(this);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          getWindow().setStatusBarColor(originalStatusBarColorFinal);
        }
      }
    });
''';

const String _androidMainActivityKotlinImportLines1 = 'import android.os.Build';
const String _androidMainActivityKotlinImportLines2 =
    'import android.view.ViewTreeObserver';
const String _androidMainActivityKotlinImportLines3 =
    'import android.view.WindowManager';

const String _androidMainActivityKotlinLines2WithStatusBar = '''
    val flutter_native_splash = true
    var originalStatusBarColor = 0
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        originalStatusBarColor = window.statusBarColor
        window.statusBarColor = {{{primaryColorDark}}}.toInt()
    }
    val originalStatusBarColorFinal = originalStatusBarColor
''';

const String _androidMainActivityKotlinLines3 = '''
    val vto = flutterView.viewTreeObserver
    vto.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        flutterView.viewTreeObserver.removeOnGlobalLayoutListener(this)
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          window.statusBarColor = originalStatusBarColorFinal
        }
      }
    })
''';

// iOS-related templates
const String _iOSLaunchScreenStoryboardContent = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="12121" systemVersion="16G29" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <deployment identifier="iOS"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="12089"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <layoutGuides>
                        <viewControllerLayoutGuide type="top" id="Ydg-fD-yQy"/>
                        <viewControllerLayoutGuide type="bottom" id="xbc-2k-c8Z"/>
                    </layoutGuides>
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4">
                            </imageView>
                        </subviews>
                        <color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                        <constraints>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1a2-6s-vTC"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="4X2-HB-R7a"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="168" height="185"/>
    </resources>
</document>
''';

String _iOSInfoPlistLines = '''
	<key>UIStatusBarHidden</key>
	<true/>
''';

String _iOSAppDelegateObjectiveCLines = '''
    int flutter_native_splash = 1;
    UIApplication.sharedApplication.statusBarHidden = false;
''';

String _iOSAppDelegateSwiftLines = '''
    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false
''';

const String _iOSContentsJson = '''
{
  "images" : [
    {
      "filename" : "LaunchImage.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "LaunchImage@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "LaunchImage@3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const String _iOSContentsJsonDark = '''
{
  "images" : [
    {
      "filename" : "LaunchImage.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "LaunchImageDark.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "LaunchImage@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "LaunchImageDark@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "LaunchImage@3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "LaunchImageDark@3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const String _iOSLaunchBackgroundJson = '''
{
  "images" : [
    {
      "filename" : "background.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const String _iOSLaunchBackgroundDarkJson = '''
{
  "images" : [
    {
      "filename" : "background.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "darkbackground.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const String _iOSLaunchBackgroundSubview = '''
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleToFill" image="LaunchBackground" translatesAutoresizingMaskIntoConstraints="NO" id="tWc-Dq-wcI">
                                <rect key="frame" x="0.0" y="0.0" width="1" height="1"/>
                            </imageView>''';

const String _iOSLaunchBackgroundConstraints = '''
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="SvB-DF-27J"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="VdF-Am-v6m"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="width" secondItem="Ze5-6b-2t3" secondAttribute="width" id="fVJ-Ko-pCh"/>
                            <constraint firstItem="tWc-Dq-wcI" firstAttribute="height" secondItem="Ze5-6b-2t3" secondAttribute="height" id="sow-8b-b2l"/>
''';
