// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PanafallFeature",
  platforms: [
    .macOS(.v13),
  ],
  
  products: [
    .library(name: "AntennaFeature", targets: ["AntennaFeature"]),
    .library(name: "BandFeature", targets: ["BandFeature"]),
    .library(name: "DaxFeature", targets: ["DaxFeature"]),
    .library(name: "DisplayFeature", targets: ["DisplayFeature"]),
    .library(name: "PanafallFeature", targets: ["PanadapterFeature", "WaterfallFeature", "PanafallFeature"]),
//    .library(name: "PanafallFeature", targets: ["WaterfallFeature"]),
//    .library(name: "PanafallFeature", targets: ["PanafallFeature"]),
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
