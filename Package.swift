// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DeveloperProfileKit",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [.library(name: "DeveloperProfileKit", targets: ["DeveloperProfileKit"])],
    dependencies: [
        .package(url: "https://github.com/Anurag-Chourasia/DesignTokensKit.git", "1.3.0"..<"2.0.0"),
        .package(url: "https://github.com/Anurag-Chourasia/UIComponentsKit.git", "1.3.0"..<"2.0.0"),
        .package(url: "https://github.com/Anurag-Chourasia/LocalizationKit.git", "0.9.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "DeveloperProfileKit",
            dependencies: [
                "DesignTokensKit",
                "UIComponentsKit",
                .product(name: "LocalizationKit", package: "LocalizationKit")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DeveloperProfileKitTests",
            dependencies: [
                "DeveloperProfileKit",
                .product(name: "LocalizationKit", package: "LocalizationKit")
            ]
        )
    ]
)
