// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataSenderApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "DataSenderCore",
            targets: ["DataSenderCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/swiftpackages/DotEnv.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "DataSenderCore",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "DotEnv", package: "DotEnv"),
            ],
            path: "Backend",
            exclude: ["MCP"]
        ),
        .testTarget(
            name: "DataSenderCoreTests",
            dependencies: ["DataSenderCore"],
            path: "Tests/UnitTests"
        ),
    ]
)