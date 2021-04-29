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
            path: "JKVValue",
            exclude: ["JKVValue.h", "Public/JKVValue.h"],
            sources:["Public", "Private"],
//            sources: ["JKVValue/Public/JKVValue.h",
//                      "JKVValue/Public/JKVFactory.h",
//                      "JKVValue/Public/JKVMutableValue.h",
//                      "JKVValue/Public/JKVObjectPrinter.h",
//                      "JKVValue/Public/JKVValueImpl.h",
//                      "JKVValue/Private/JKVClassInspector.h",
//                      "JKVValue/Private/JKVKeyedDecoderVisitor.h",
//                      "JKVValue/Private/JKVKeyedEncoderVisitor.h",
//                      "JKVValue/Private/JKVNonZeroSetterVisitor.h",
//                      "JKVValue/Private/JKVObjectPrinter-Protected.h",
//                      "JKVValue/Private/JKVProperty.h"],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("Public"),
                .headerSearchPath("Private")
            ])
    ]
)
