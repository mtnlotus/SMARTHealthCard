// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SMARTHealthCard",
	platforms: [
		.macOS(.v15),
		.iOS(.v17),
	],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "SMARTHealthCard",
			targets: ["SMARTHealthCard"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/FHIRModels.git", "0.7.0"..<"1.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "SMARTHealthCard",
			dependencies: [
				.product(name: "ModelsR4", package: "FHIRModels"),
			]
		),
		.testTarget(
			name: "SMARTHealthCardTests",
			dependencies: ["SMARTHealthCard"],
			resources: [.copy("TestData")]
		),
	]
)
