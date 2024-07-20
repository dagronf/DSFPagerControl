// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "DSFPagerControl",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(name: "DSFPagerControl", targets: ["DSFPagerControl"]),
		.library(name: "DSFPagerControl-static", type: .static, targets: ["DSFPagerControl"]),
		.library(name: "DSFPagerControl-shared", type: .dynamic, targets: ["DSFPagerControl"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", .upToNextMinor(from: "3.5.0")),
	],
	targets: [
		.target(
			name: "DSFPagerControl",
			dependencies: ["DSFAppearanceManager"]),
		.testTarget(
			name: "DSFPagerControlTests",
			dependencies: ["DSFPagerControl"]),
	]
)
