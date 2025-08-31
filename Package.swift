// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ItemsBrowserKit",
    platforms: [
        .iOS(.v15)
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
