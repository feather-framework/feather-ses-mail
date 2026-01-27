// swift-tools-version:6.1
import PackageDescription

var defaultSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableExperimentalFeature(
        "AvailabilityMacro=FeatherMailAvailability:macOS 15, iOS 16, watchOS 9, tvOS 16, visionOS 1"
    ),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableExperimentalFeature("Lifetimes"),
]

#if compiler(>=6.2)
defaultSwiftSettings.append(
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
)
#endif

let package = Package(
    name: "feather-mail-driver-ses",
    platforms: [
        .macOS(.v10_15)      //soto needs it !
    ],
    products: [
        .library(name: "FeatherMailDriverSES", targets: ["FeatherMailDriverSES"]),
    ],
    dependencies: [
        // [docc-plugin-placeholder]
        .package(url: "https://github.com/soto-project/soto-core", from: "7.0.0"),
        .package(url: "https://github.com/soto-project/soto", from: "7.0.0"),
        //.package(url: "https://github.com/feather-framework/feather-mail.git", .upToNextMinor(from: "1.0.0-beta.1")),
        .package(path: "../feather-mail"),
    ],
    targets: [
        .target(
            name: "FeatherMailDriverSES",
            dependencies: [
                .product(name: "FeatherMail", package: "feather-mail"),
                .product(name: "SotoSESv2", package: "soto"),
                .product(name: "SotoCore", package: "soto-core"),
            ]
        ),
        .testTarget(
            name: "FeatherMailDriverSESTests",
            dependencies: [
                .product(name: "FeatherMail", package: "feather-mail"),
                .target(name: "FeatherMailDriverSES"),
            ]
        ),
    ]
)
