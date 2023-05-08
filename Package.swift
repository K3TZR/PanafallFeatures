// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PanFeature",
  platforms: [
    .macOS(.v13),
  ],
  
  products: [
//    .library(name: "AntennaFeature", targets: ["AntennaFeature"]),
//    .library(name: "BandFeature", targets: ["BandFeature"]),
//    .library(name: "DaxFeature", targets: ["DaxFeature"]),
//    .library(name: "DisplayFeature", targets: ["DisplayFeature"]),
    .library(name: "PanafallFeature", targets: ["PanafallFeature"]),
  ],
  
  dependencies: [
    // ----- K3TZR -----
    .package(url: "https://github.com/K3TZR/ApiFeature.git", branch: "main"),
    // ----- OTHER -----
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.42.0"),
  ],

  // --------------- Modules ---------------
  targets: [
    // PanafallAntennaFeature
    .target(name: "PanafallAntennaFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "Shared", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // PanafallBandFeature
    .target(name: "PanafallBandFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "Shared", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // PanafallDaxFeature
    .target(name: "PanafallDaxFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "Shared", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // PanafallDisplayFeature
    .target(name: "PanafallDisplayFeature",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "Shared", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // PanafallFeature
    .target(name: "PanafallFeature",
            dependencies: [
              "PanafallAntennaFeature",
              "PanafallBandFeature",
              "PanafallDaxFeature",
              "PanafallDisplayFeature",
              .product(name: "FlexApi", package: "ApiFeature"),
              .product(name: "Shared", package: "ApiFeature"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
  ]

  // --------------- Tests ---------------
)
