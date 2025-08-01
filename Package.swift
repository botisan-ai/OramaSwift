// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "OramaSwift",
  platforms: [
      .macOS(.v11), .iOS(.v14),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "OramaSwift",
      targets: ["OramaSwift"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/shareup/wasm-interpreter-apple.git",
      from: "0.8.1"
    )
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "OramaSwift",
      dependencies: [
        .product(name: "WasmInterpreter", package: "wasm-interpreter-apple")
      ],
      resources: [
        .copy("JavaScript"),
        .copy("Wasm")
      ]),
    .testTarget(
      name: "OramaSwiftTests",
      dependencies: ["OramaSwift"]
    ),
  ]
)
