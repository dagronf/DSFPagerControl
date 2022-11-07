// swift-tools-version:5.3

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
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "3.3.0"),
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
