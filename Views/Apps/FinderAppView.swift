import SwiftUI

struct FinderAppView: View {
    @State private var selectedItem: FinderItem? = nil
    @State private var currentPath: [FinderItem] = []
    @State private var viewStyle: ViewStyle = .icons

    enum ViewStyle { case icons, list }

    // Mock file system
    let rootItems: [FinderItem] = [
        FinderItem(name: "Applications", icon: "square.grid.2x2.fill", color: .blue, isFolder: true, children: [
            FinderItem(name: "Calculator", icon: "plus.forwardslash.minus", color: .black, isFolder: false),
            FinderItem(name: "Notes",      icon: "note.text",               color: .yellow, isFolder: false),
            FinderItem(name: "Weather",    icon: "cloud.sun.fill",          color: .cyan, isFolder: false),
            FinderItem(name: "Safari",     icon: "safari",                  color: .green, isFolder: false)
        ]),
        FinderItem(name: "Documents", icon: "folder.fill", color: .blue, isFolder: true, children: [
            FinderItem(name: "Resume.pdf",  icon: "doc.fill",       color: .red,  isFolder: false, size: "124 KB"),
            FinderItem(name: "Notes.txt",   icon: "doc.text.fill",  color: .gray, isFolder: false, size: "4 KB"),
            FinderItem(name: "Budget.xlsx", icon: "tablecells.fill", color: .green, isFolder: false, size: "38 KB")
        ]),
        FinderItem(name: "Downloads", icon: "arrow.down.circle.fill", color: .blue, isFolder: true, children: [
            FinderItem(name: "photo.jpg", icon: "photo.fill", color: .purple, isFolder: false, size: "2.4 MB"),
            FinderItem(name: "movie.mp4", icon: "film.fill",  color: .red,    isFolder: false, size: "512 MB")
        ]),
        FinderItem(name: "Desktop", icon: "desktopcomputer", color: .blue, isFolder: true, children: []),
        FinderItem(name: "Pictures", icon: "photo.on.rectangle.angled", color: .orange, isFolder: true, children: [
            FinderItem(name: "Vacation",    icon: "folder.fill", color: .blue,   isFolder: true),
            FinderItem(name: "Profile.png", icon: "photo.fill",  color: .purple, isFolder: false, size: "890 KB")
        ])
    ]

    var currentItems: [FinderItem] {
        currentPath.last?.children ?? rootItems
    }

    var pathString: String {
        (["Macintosh HD"] + currentPath.map(\.name)).joined(separator: " › ")
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                Text("Favourites")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                ForEach(rootItems) { item in
                    FinderSidebarRow(item: item, isSelected: selectedItem?.id == item.id) {
                        selectedItem = item
                        currentPath = [item]
                    }
                }
                Spacer()
            }
            .frame(width: 160)
            .background(Color(.systemGray6))

            Divider()

            // Main area
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button {
                        if !currentPath.isEmpty { currentPath.removeLast() }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(currentPath.isEmpty)
                    .buttonStyle(.plain)

                    Text(pathString)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer()

                    Picker("View", selection: $viewStyle) {
                        Image(systemName: "square.grid.2x2").tag(ViewStyle.icons)
                        Image(systemName: "list.bullet").tag(ViewStyle.list)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))

                Divider()

                ScrollView {
                    if viewStyle == .icons {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 90))], spacing: 12) {
                            ForEach(currentItems) { item in
                                FinderIconCell(item: item) {
                                    if item.isFolder {
                                        currentPath.append(item)
                                        selectedItem = item
                                    }
                                }
                            }
                        }
                        .padding(12)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(currentItems) { item in
                                FinderListRow(item: item) {
                                    if item.isFolder {
                                        currentPath.append(item)
                                        selectedItem = item
                                    }
                                }
                                Divider()
                            }
                        }
                    }

                    if currentItems.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "folder")
                                .font(.system(size: 48))
                                .foregroundStyle(.tertiary)
                            Text("This folder is empty")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)
                    }
                }
                .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Finder Item Model
struct FinderItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let isFolder: Bool
    var size: String = "--"
    var children: [FinderItem] = []
    var dateModified: String = "Today"
}

// MARK: - Sidebar Row
struct FinderSidebarRow: View {
    let item: FinderItem
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .foregroundStyle(item.color)
                    .frame(width: 16)
                Text(item.name)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor.opacity(0.15) : (isHovered ? Color.primary.opacity(0.06) : Color.clear))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .padding(.horizontal, 6)
    }
}

// MARK: - Icon Cell
struct FinderIconCell: View {
    let item: FinderItem
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if item.isFolder {
                        Image(systemName: item.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(item.color)
                            .frame(width: 52, height: 52)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.color.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: item.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(item.color)
                    }
                }
                Text(item.name)
                    .font(.system(size: 11))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(6)
            .background(isHovered ? Color.accentColor.opacity(0.12) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - List Row
struct FinderListRow: View {
    let item: FinderItem
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .foregroundStyle(item.color)
                    .frame(width: 20)
                Text(item.name)
                    .font(.system(size: 13))
                Spacer()
                Text(item.dateModified)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                Text(item.isFolder ? "--" : item.size)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
