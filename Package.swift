// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PanafallFeatures",
  platforms: [
    .macOS(.v13),
  ],
  
  products: [
    .library(name: "AntennaPopover", targets: ["AntennaPopover"]),
    .library(name: "BandPopover", targets: ["BandPopover"]),
    .library(name: "DaxPopover", targets: ["DaxPopover"]),
    .library(name: "DisplayPopover", targets: ["DisplayPopover"]),
    .library(name: "Panadapter", targets: ["Panadapter"]),
    .library(name: "Panafall", targets: ["Panafall"]),
    .library(name: "Panafalls", targets: ["Panafalls"]),
    .library(name: "Waterfall", targets: ["Waterfall"]),
  ],
  
  dependencies: [
    // ----- K3TZR -----
    .package(url: "https://github.com/K3TZR/ApiFeatures.git", branch: "main"),
    // ----- OTHER -----
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.42.0"),
  ],

  // --------------- Modules ---------------
  targets: [
    // AntennaPopover
    .target(name: "AntennaPopover",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    
    // BandPopover
    .target(name: "BandPopover",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // DaxPopover
    .target(name: "DaxPopover",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // DisplayPopover
    .target(name: "DisplayPopover",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // Panadapter
    .target(name: "Panadapter",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // Panafall
    .target(name: "Panafall",
            dependencies: [
              "Panadapter",
              "AntennaPopover",
              "BandPopover",
              "DaxPopover",
              "DisplayPopover",
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // Panafalls
    .target(name: "Panafalls",
            dependencies: [
              "Panafall",
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),

    // Waterfall
    .target(name: "Waterfall",
            dependencies: [
              .product(name: "FlexApi", package: "ApiFeatures"),
              .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
  ]

  // --------------- Tests ---------------
)
