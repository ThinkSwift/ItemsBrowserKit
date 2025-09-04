import PackageDescription

let package = Package(
    name: "ItemsBrowserKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        //.visionOS(.v1)
    ],
    products: [
        .library(name: "ItemsBrowserKit", targets: ["ItemsBrowserKit"])
    ],
    targets: [
        .target(
            name: "ItemsBrowserKit",
            path: "Sources/ItemsBrowserKit"
        ),
        .testTarget(
            name: "ItemsBrowserKitTests",
            dependencies: ["ItemsBrowserKit"]
        )
    ]
)

