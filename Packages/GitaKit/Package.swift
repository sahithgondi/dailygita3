// swift-tools-version: 5.9
import PackageDescription

// Local Swift package shared by both the app and the widget extension (impl plan §4).
// All models, persistence, and the deterministic daily-verse logic live here so there is a
// single source of truth — no duplicated models across targets (CLAUDE.md §5).
//
// Platforms: the app ships iOS 17+. `.macOS(.v14)` is declared *only* so `swift test` and CI can
// build/run the unit tests on the macOS host (SwiftData needs macOS 14+). The shipped app is iOS.
let package = Package(
    name: "GitaKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "GitaKit", targets: ["GitaKit"]),
    ],
    targets: [
        .target(name: "GitaKit"),
        .testTarget(name: "GitaKitTests", dependencies: ["GitaKit"]),
    ]
)
