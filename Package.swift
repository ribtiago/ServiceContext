// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceContext",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(
            name: "ServiceContext",
            targets: ["ServiceContext"]),
    ],
    targets: [
        .target(name: "ServiceContext")
    ]
)
