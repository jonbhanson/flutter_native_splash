#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_splash.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_splash'
  s.version          = '2.4.3'
  s.summary          = 'Flutter Native Splash'
  s.description      = <<-DESC
Customize Flutter's default white native splash screen with background color and splash image. Supports dark mode, full screen, and more.
                       DESC
  s.homepage         = 'https://github.com/jonbhanson/flutter_native_splash'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jon Hanson' => 'jon@jonhanson.net' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_native_splash/Sources/flutter_native_splash/**/*.{h,m}'
  s.public_header_files = 'flutter_native_splash/Sources/flutter_native_splash/include/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.resource_bundles = {'flutter_native_splash_privacy' => ['flutter_native_splash/Sources/flutter_native_splash/PrivacyInfo.xcprivacy']}

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
