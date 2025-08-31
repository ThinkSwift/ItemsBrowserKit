# ItemsBrowserKit

SwiftUI generic items browser: grid/list toggle, edit & delete, thumbnail loader with async, and simple sorting by `updatedAt`.

- **iOS 15+**
- **No external dependencies**
- **Generic over your model** via `BrowserItem` protocol

---

## Installation (Swift Package Manager)

### Xcode
- File → Add Packages…
- URL: `https://github.com/ThinkSwift/ItemsBrowserKit.git`
- Add `ItemsBrowserKit` to your target.

### Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/<your-account>/ItemsBrowserKit.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["ItemsBrowserKit"]
    )
]
