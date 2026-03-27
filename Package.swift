// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CoordinatorKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
        .tvOS(.v13),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "CoordinatorKit",
            targets: ["CoordinatorKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "600.0.0"
        )
    ],
    targets: [
        .macro(
            name: "CoordinatorKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "CoordinatorKit",
            dependencies: ["CoordinatorKitMacros"]
        ),
        .testTarget(
            name: "CoordinatorKitTests",
            dependencies: [
                "CoordinatorKit",
                "CoordinatorKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
