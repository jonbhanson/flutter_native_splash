package com.example.example;

import android.animation.Animator;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.SplashScreen;

public class MainActivity extends FlutterActivity {

    // By default, Flutter makes a 1/2 second fade between the native splash screen
    // and the first Flutter frame.  However, loading an image for a secondary splash
    // screen takes a moment, causing a flash that can be observed in spite of the fade.
    // To prevent this, a CustomSplashScreen is used that keeps the splash screen
    // visible over the Flutter app 1/2 second to conceal the flash from the image loading.
    // To restore the Flutter default behavior, remove the contents of MainActivity and
    // the CustomSplashScreen class.

    @Nullable
    @Override
    public SplashScreen provideSplashScreen() {
        Drawable manifestSplashDrawable = getSplashScreenFromManifest();
        if (manifestSplashDrawable != null) {
            return new CustomSplashScreen(manifestSplashDrawable);
        } else {
            return null;
        }
    }

    /* package */ static final String SPLASH_SCREEN_META_DATA_KEY =
            "io.flutter.embedding.android.SplashScreenDrawable";

    @Nullable
    private Drawable getSplashScreenFromManifest() {
        try {
            Bundle metaData = getMetaData();
            int splashScreenId = metaData != null ? metaData.getInt(SPLASH_SCREEN_META_DATA_KEY) : 0;
            return splashScreenId != 0
                    ? Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP
                    ? getResources().getDrawable(splashScreenId, getTheme())
                    : getResources().getDrawable(splashScreenId)
                    : null;
        } catch (PackageManager.NameNotFoundException e) {
            // This is never expected to happen.
            return null;
        }
    }
}

class CustomSplashScreen implements SplashScreen {
    private final Drawable drawable;
    private io.flutter.embedding.android.DrawableSplashScreen.DrawableSplashScreenView splashView;

    public CustomSplashScreen(@NonNull Drawable drawable) {
        this.drawable = drawable;
    }

    @Nullable
    @Override
    public View createSplashView(@NonNull Context context, @Nullable Bundle savedInstanceState) {
        splashView = new io.flutter.embedding.android.DrawableSplashScreen.DrawableSplashScreenView(context);
        splashView.setSplashDrawable(drawable, ImageView.ScaleType.FIT_XY);
        return splashView;
    }

    @Override
    public void transitionToFlutter(@NonNull Runnable onTransitionComplete) {
        if (splashView == null) {
            onTransitionComplete.run();
            return;
        }

        splashView
                .animate()
                .alpha(1.0f)
                .setDuration(500)
                .setListener(
                        new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {}

                            @Override
                            public void onAnimationEnd(Animator animation) {
                                onTransitionComplete.run();
                            }

                            @Override
                            public void onAnimationCancel(Animator animation) {
                                onTransitionComplete.run();
                            }

                            @Override
                            public void onAnimationRepeat(Animator animation) {}
                        });
    }
}
