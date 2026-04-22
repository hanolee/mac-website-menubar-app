// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WebsiteMenuBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "WebsiteMenuBar",
            path: "Sources/WebsiteMenuBar"
        )
    ]
)
