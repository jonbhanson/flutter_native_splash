// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_native_splash",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flutter-native-splash", targets: ["flutter_native_splash"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_native_splash",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            cSettings: [
                .headerSearchPath("include/flutter_native_splash")
            ]
        )
    ]
)
