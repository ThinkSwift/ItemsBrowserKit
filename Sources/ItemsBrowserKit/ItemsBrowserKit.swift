import SwiftUI

public protocol BrowserItem {
    var anyID: AnyHashable { get }
    var title: String? { get }
    var subtitle: String? { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var thumbnail: Image? { get }
    var loadThumbnail: (() async -> Image?)? { get }
}

public struct BrowserConfig {
    public var gridAdaptiveMin: CGFloat
    public var thumbSize: CGFloat
    public var thumbCorner: CGFloat
    public var showsLayoutToggle: Bool
    public var showsEdit: Bool
    public var showsAdd: Bool   // kept for compatibility, unused when false

    public init(
        gridAdaptiveMin: CGFloat = 120,
        thumbSize: CGFloat = 64,
        thumbCorner: CGFloat = 10,
        showsLayoutToggle: Bool = true,
        showsEdit: Bool = true,
        showsAdd: Bool = false   // default false per new requirement
    ) {
        self.gridAdaptiveMin = gridAdaptiveMin
        self.thumbSize = thumbSize
        self.thumbCorner = thumbCorner
        self.showsLayoutToggle = showsLayoutToggle
        self.showsEdit = showsEdit
        self.showsAdd = showsAdd
    }
}

/// Browser with Back on the left, Edit on the right (→ Trash + Done while editing),
/// updated-date sorting (asc/desc), and unified thumbnail.
public struct ItemsBrowser<Item: BrowserItem, Cell: View>: View {
    private let items: [Item]
    private let config: BrowserConfig
    private let onOpen: (Item) -> Void
    private let onDelete: ([Item]) -> Void
    private let onClose: (() -> Void)?
    private let textPreview: ((Item) -> String?)?
    @ViewBuilder private let cell: (Item, Bool) -> Cell

    @State private var isGrid = true
    @State private var isEditing = false
    @State private var updatedDesc = true
    @State private var selection = Set<AnyHashable>()
    @State private var pulseIDs = Set<AnyHashable>()   // tap bounce per-tile

    public init(
        items: [Item],
        config: BrowserConfig = .init(),
        textPreview: ((Item) -> String?)? = nil,
        onOpen: @escaping (Item) -> Void,
        onDelete: @escaping ([Item]) -> Void,
        onClose: (() -> Void)? = nil,
        @ViewBuilder cell: @escaping (Item, Bool) -> Cell
    ) {
        self.items = items
        self.config = config
        self.textPreview = textPreview
        self.onOpen = onOpen
        self.onDelete = onDelete
        self.onClose = onClose
        self.cell = cell
    }

    public var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            content
        }
        .animation(.default, value: isGrid)
        .animation(.default, value: isEditing)
        .animation(.default, value: updatedDesc)
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            // Left: Back
            if let onClose {
                Button {
                    onClose()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            // Right: sort / layout / edit or trash+done
            Button { updatedDesc.toggle() } label: {
                Image(systemName: updatedDesc ? "arrow.down" : "arrow.up")
            }
            .buttonStyle(.bordered)

            if config.showsLayoutToggle {
                Button { isGrid.toggle() } label: {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                }
                .buttonStyle(.bordered)
            }

            if config.showsEdit {
                if isEditing {
                    Button(role: .destructive) {
                        let data = sorted(items, desc: updatedDesc)
                        let picked = data.filter { selection.contains($0.anyID) }
                        onDelete(picked)
                        selection.removeAll()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selection.isEmpty)

                    Button("Done") { isEditing = false; selection.removeAll() }
                        .buttonStyle(.bordered)
                } else {
                    Button("Edit") { isEditing = true }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Content

    private var content: some View {
        let data = sorted(items, desc: updatedDesc)
        return Group {
            if data.isEmpty { emptyState }
            else if isGrid { grid(data) }
            else { list(data) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray").font(.system(size: 40))
            Text("No items").foregroundStyle(.secondary)
        }
        .padding(40)
    }

    private func grid(_ data: [Item]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: config.gridAdaptiveMin), spacing: 12)],
                spacing: 12
            ) {
                ForEach(data, id: \.anyID) { item in
                    let selected = selection.contains(item.anyID)
                    let pulsing = pulseIDs.contains(item.anyID)

                    VStack(alignment: .leading, spacing: 6) {
                        UnifiedThumbnail(
                            item: item,
                            size: config.thumbSize,
                            corner: config.thumbCorner,
                            textPreview: textPreview
                        )
                        .frame(maxWidth: .infinity) // fill column width

                        cell(item, selected)

                        if let t = displayTitle(item) {
                            Text(t).font(.footnote).lineLimit(1)
                        }
                        if let s = item.subtitle {
                            Text(s).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .topTrailing) { checkmark(selected) }
                    .scaleEffect(pulsing ? 0.96 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pulsing)
                    .onTapGesture { tap(item) }
                    .contextMenu { contextMenu(for: item) }
                    .frame(maxWidth: .infinity) // keep equal width per column
                }
            }
            .padding(12)
        }
    }

    private func list(_ data: [Item]) -> some View {
        List(data, id: \.anyID) { item in
            let selected = selection.contains(item.anyID)
            let pulsing = pulseIDs.contains(item.anyID)
            HStack(spacing: 12) {
                UnifiedThumbnail(
                    item: item,
                    size: config.thumbSize,
                    corner: config.thumbCorner,
                    textPreview: textPreview
                )
                .clipShape(RoundedRectangle(cornerRadius: config.thumbCorner))

                VStack(alignment: .leading, spacing: 2) {
                    if let t = displayTitle(item) { Text(t).lineLimit(1) }
                    if let s = item.subtitle {
                        Text(s).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
                Spacer()
                if isEditing {
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selected ? Color.accentColor : .secondary)
                }
            }
            .scaleEffect(pulsing ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: pulsing)
            .contentShape(Rectangle())
            .onTapGesture { tap(item) }
            .contextMenu { contextMenu(for: item) }
        }
        .listStyle(.plain)
    }

    // MARK: - Actions & helpers

    private func checkmark(_ selected: Bool) -> some View {
        Group {
            if isEditing {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(selected ? Color.accentColor : .secondary)
                    .padding(6)
            }
        }
    }

    private func contextMenu(for item: Item) -> some View {
        Group {
            Button("Open") { onOpen(item) }
            if isEditing {
                if selection.contains(item.anyID) {
                    Button("Deselect") { selection.remove(item.anyID) }
                } else {
                    Button("Select") { selection.insert(item.anyID) }
                }
            }
            Divider()
            Button(role: .destructive) {
                onDelete([item])
                selection.remove(item.anyID)
            } label: { Label("Delete", systemImage: "trash") }
        }
    }

    private func tap(_ item: Item) {
        if isEditing {
            if selection.contains(item.anyID) { selection.remove(item.anyID) }
            else { selection.insert(item.anyID) }
            // tiny pulse feedback
            pulse(item.anyID)
        } else {
            pulse(item.anyID)
            onOpen(item)
        }
    }

    private func pulse(_ id: AnyHashable) {
        pulseIDs.insert(id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            pulseIDs.remove(id)
        }
    }

    private func sorted(_ items: [Item], desc: Bool) -> [Item] {
        desc ? items.sorted { $0.updatedAt > $1.updatedAt }
             : items.sorted { $0.updatedAt < $1.updatedAt }
    }

    private func displayTitle(_ item: Item) -> String? {
        let t = item.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (t?.isEmpty == true) ? nil : t
    }
}

// MARK: - Unified thumbnail (image or text tile)
private struct UnifiedThumbnail<Item: BrowserItem>: View {
    let item: Item
    let size: CGFloat
    let corner: CGFloat
    let textPreview: ((Item) -> String?)?

    @State private var img: Image? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner).fill(.ultraThinMaterial)

            if let picture = img ?? item.thumbnail {
                picture.resizable().scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: corner))
            } else if let text = textPreview?(item), !text.isEmpty {
                TextTile(text: text)
            } else {
                Image(systemName: "doc")
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .task(id: item.updatedAt.timeIntervalSinceReferenceDate) {
          img = nil
          guard let loader = item.loadThumbnail else { return }
          if let got = await loader() {
            await MainActor.run { img = got } // UI state on main
          }
        }
    }
}

private struct TextTile: View {
    let text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(.thinMaterial)
            Text(text)
                .font(.caption2)
                .multilineTextAlignment(.leading)
                .lineLimit(6)
                .padding(8)
        }
        .compositingGroup()
        .clipped()
    }
}
