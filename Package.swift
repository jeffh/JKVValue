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
//            dependencies: [
//                .target(name: "JKVValuePrivate")
//            ],
            path: "JKVValue/Source",
//            exclude: ["JKVValue.h", "Public/JKVValue.h"],
//            sources:["Public", "Private"],
//            sources: ["Public/JKVFactory.h",
//                      "Public/JKVMutableValue.h",
//                      "Public/JKVObjectPrinter.h",
//                      "Public/JKVValueImpl.h",
//                      "Private/JKVClassInspector.h",
//                      "Private/JKVKeyedDecoderVisitor.h",
//                      "Private/JKVKeyedEncoderVisitor.h",
//                      "Private/JKVNonZeroSetterVisitor.h",
//                      "Private/JKVObjectPrinter-Protected.h",
//                      "Private/JKVProperty.h"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Public"),
                .headerSearchPath("Private")
            ]
        )
    ]
)
