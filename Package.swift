// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WindowFlow",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "WindowFlow",
            path: "Sources/WindowFlow",
            resources: [
                .copy("../../Resources/Info.plist")
            ]
        )
    ]
)
