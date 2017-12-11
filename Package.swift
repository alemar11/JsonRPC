// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "JsonRPC",
  products: [
    .library(name: "JsonRPC", targets: ["JsonRPC"])
  ],
  targets: [
    .target(name: "JsonRPC", path: "Sources"),
    .testTarget(name: "JsonRPCTests", dependencies: ["JsonRPC"])
  ],
    swiftLanguageVersions: [4]
)

