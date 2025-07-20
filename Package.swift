// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LiquidKit",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .watchOS(.v11),
    .tvOS(.v18)
  ],
  products: [
    .library(
      name: "LiquidKit",
      targets: ["LiquidKit"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/Kitura/swift-html-entities.git",
      from: "4.0.1"
    )
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "LiquidKit",
      dependencies: [
        .product(
          name: "HTMLEntities",
          package: "swift-html-entities"
        )
      ]
    ),
    .testTarget(
      name: "LiquidKitTests",
      dependencies: ["LiquidKit"],
      resources: [
        .copy("Resources")
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)

