// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "JKVValue",
    platforms: [.iOS(.v9), .macOS(.v10_10), .tvOS(.v9)],
    products: [
        .library(
            name: "JKVValue",
            targets: ["JKVValue"])
    ],
    targets: [
        .target(
            name: "JKVValue",
            path: "JKVValue/Source",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Public"),
                .headerSearchPath("Private")
            ]
        )
    ]
)
