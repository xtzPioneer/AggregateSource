// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AggregateSource",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "AggregateSource",
            targets: ["AggregateSource"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/tid-kijyun/Kanna.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/malcommac/SwiftDate.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(
            name: "AggregateSource",
            dependencies: [
                "Alamofire",
                "CombineExt",
                "Kanna",
                "SwiftDate",
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AggregateSourceTests",
            dependencies: ["AggregateSource"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
