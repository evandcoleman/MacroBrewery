// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MacroBrewery",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "MacroBrewery",
            targets: ["MacroBrewery"]
        ),
        .executable(
            name: "MacroBreweryClient",
            targets: ["MacroBreweryClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "MacroBreweryMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "MacroBrewery",
            dependencies: ["MacroBreweryMacros"]
        ),
        .executableTarget(
            name: "MacroBreweryClient",
            dependencies: ["MacroBrewery"]
        ),
        .testTarget(
            name: "MacroBreweryTests",
            dependencies: [
                "MacroBreweryMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
