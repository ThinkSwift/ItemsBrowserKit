# ItemsBrowserKit

A lightweight, generic SwiftUI browser for your items — grid/list toggle, multi-select delete, async thumbnails, and simple updated-time sorting.

- **iOS 15+**
- **No external dependencies**
- **Bring-your-own model** via `BrowserItem`

---

## Installation

**Xcode** → **File** → **Add Packages…**  
Paste this repository URL: `https://github.com/<your-username>/ItemsBrowserKit.git`  
(Replace `<your-username>` with your GitHub account or org.)

---

## Quick Start

### 1) Conform your model

```swift
import SwiftUI
import ItemsBrowserKit

struct Doc: BrowserItem {
    var anyID: AnyHashable
    var title: String?
    var subtitle: String?
    var createdAt: Date
    var updatedAt: Date
    var thumbnail: Image?
    var loadThumbnail: (() async -> Image?)?
}
