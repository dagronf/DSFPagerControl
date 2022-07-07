// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFPagerControl",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(name: "DSFPagerControl", type: .static, targets: ["DSFPagerControl"]),
		.library(name: "DSFPagerControl-shared", type: .dynamic, targets: ["DSFPagerControl"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFAppearanceManager", from: "2.0.0"),
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
