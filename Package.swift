// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LiteCount",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "LiteCount", targets: ["LiteCount"])],
    targets: [
        .executableTarget(
            name: "LiteCount",
            path: "Sources/LiteCount"
        )
    ]
)
