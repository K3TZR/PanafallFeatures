// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PanafallFeatures",
  platforms: [
    .macOS(.v13),
  ],
  
  products: [
    .library(name: "PanafallFeatures", targets: [
      "AntennaFeature",
      "BandFeature",
      "DaxFeature",
      "DisplayFeature",
      "PanadapterFeature",
      "PanafallFeature",
      "WaterfallFeature",
    ]),
  ],
  
  dependencies: [
    // ----- K3TZR -----
    .package(url: "https://github.com/K3TZR/ApiFeature.git", branch: "main"),
    // ----- OTHER -----
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.42.0"),
  ],

  // --------------- Modules ---------------
  targets: [
    // AntennaFeature
    .target(name: "AntennaFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // BandFeature
    .target(name: "BandFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // DaxFeature
    .target(name: "DaxFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // DisplayFeature
    .target(name: "DisplayFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // PanadapterFeature
    .target(name: "PanadapterFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // PanafallFeature
    .target(name: "PanafallFeature",
            dependencies: [
              "AntennaFeature",
              "BandFeature",
              "DaxFeature",
              "DisplayFeature",
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // WaterfallFeature
    .target(name: "WaterfallFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
  ]

  // --------------- Tests ---------------
)
