# ItemsBrowserKit

A lightweight, generic SwiftUI browser for your items — grid/list toggle, multi-select delete, async thumbnails, and updated-time sorting.

- **iOS 15+**
- **No external dependencies**
- **Bring-your-own model** via `BrowserItem`

---

## Installation

### Xcode (recommended)
1. **File → Add Packages…**
2. Paste: `https://github.com/ThinkSwift/ItemsBrowserKit.git`
3. Add **ItemsBrowserKit** to your app target.

### Package.swift
Using a version tag:
```swift
dependencies: [
    .package(url: "https://github.com/ThinkSwift/ItemsBrowserKit.git", from: "0.1.0")
]
