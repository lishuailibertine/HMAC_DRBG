// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HMAC_DRBG",
    platforms: [
        .macOS("12.0"),
        .iOS("13.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HMAC_DRBG",
            targets: ["HMAC_DRBG"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt", from: "5.0.0") // replace with swift-numerics when PR #84 is merged
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HMAC_DRBG",
            dependencies: ["BigInt"]),
        .testTarget(
            name: "HMAC_DRBGTests",
            dependencies: ["HMAC_DRBG"]),
    ]
)
