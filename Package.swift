// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DeveloperProfileKit",
    platforms: [.iOS("16.6"), .macOS(.v14)],
    products: [.library(name: "DeveloperProfileKit", targets: ["DeveloperProfileKit"])],
    dependencies: [
        .package(url: "https://github.com/Anurag-Chourasia/DesignTokensKit.git", exact: "1.2.0"),
        .package(url: "https://github.com/Anurag-Chourasia/UIComponentsKit.git", exact: "1.2.0")
    ],
    targets: [
        .target(name: "DeveloperProfileKit", dependencies: ["DesignTokensKit", "UIComponentsKit"], resources: [.process("Resources")]),
        .testTarget(name: "DeveloperProfileKitTests", dependencies: ["DeveloperProfileKit"])
    ]
)
