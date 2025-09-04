// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ItemsBrowserKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ItemsBrowserKit", targets: ["ItemsBrowserKit"])
    ],
    targets: [
        .target(
            name: "ItemsBrowserKit",
            path: "Sources/ItemsBrowserKit"
        )
    ]
)


