import SwiftUI

struct MenuBarView: View {
    @Environment(DesktopViewModel.self) private var vm
    let screenSize: CGSize

    @State private var showAppleMenu    = false
    @State private var showFileMenu     = false
    @State private var showEditMenu     = false
    @State private var showViewMenu     = false
    @State private var currentTime      = Date()

    let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "EEE MMM d  h:mm a"
        return f.string(from: currentTime)
    }

    var body: some View {
        ZStack {
            // Blur background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)

            HStack(spacing: 0) {

                // MARK: Apple Logo
                MenuBarButton(label: "") {
                    showAppleMenu.toggle()
                    closeOtherMenus(except: "apple")
                }
                .popover(isPresented: $showAppleMenu, arrowEdge: .top) {
                    AppleMenuContent()
                }

                // MARK: Active App Name
                Text(activeAppName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)

                // MARK: File
                MenuBarButton(label: "File") {
                    showFileMenu.toggle()
                    closeOtherMenus(except: "file")
                }
                .popover(isPresented: $showFileMenu, arrowEdge: .top) {
                    FileMenuContent()
                }

                // MARK: Edit
                MenuBarButton(label: "Edit") {
                    showEditMenu.toggle()
                    closeOtherMenus(except: "edit")
                }
                .popover(isPresented: $showEditMenu, arrowEdge: .top) {
                    EditMenuContent()
                }

                // MARK: View
                MenuBarButton(label: "View") {
                    showViewMenu.toggle()
                    closeOtherMenus(except: "view")
                }
                .popover(isPresented: $showViewMenu, arrowEdge: .top) {
                    ViewMenuContent()
                }

                Spacer()

                // MARK: Status Items
                HStack(spacing: 12) {
                    Image(systemName: "wifi")
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "battery.100")
                        .font(.system(size: 12, weight: .medium))
                    Text(formattedTime)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.primary)
                .padding(.trailing, 12)
            }
            .frame(height: 28)
        }
        .frame(height: 28)
        .onReceive(clockTimer) { _ in currentTime = Date() }
    }

    private var activeAppName: String {
        if let id = vm.activeWindowId,
           let win = vm.openWindows.first(where: { $0.id == id }) {
            return win.appType.rawValue
        }
        return "Finder"
    }

    private func closeOtherMenus(except: String) {
        if except != "apple" { showAppleMenu = false }
        if except != "file"  { showFileMenu  = false }
        if except != "edit"  { showEditMenu  = false }
        if except != "view"  { showViewMenu  = false }
    }
}

// MARK: - Menu Bar Button
struct MenuBarButton: View {
    let label: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Group {
                if label.isEmpty {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 14, weight: .medium))
                } else {
                    Text(label)
                        .font(.system(size: 13))
                }
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(isHovered ? Color.primary.opacity(0.12) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Apple Menu
struct AppleMenuContent: View {
    @Environment(DesktopViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MenuItemRow(title: "About This Mac",       icon: "info.circle")  { dismiss() }
            Divider()
            MenuItemRow(title: "System Settings...",   icon: "gearshape")    { dismiss() }
            Divider()
            MenuItemRow(title: "Sleep",                icon: "moon.fill")    { dismiss() }
            MenuItemRow(title: "Restart…",             icon: "arrow.clockwise") { dismiss() }
            MenuItemRow(title: "Shut Down…",           icon: "power")        { dismiss() }
        }
        .frame(width: 220)
        .padding(.vertical, 4)
    }
}

// MARK: - File Menu
struct FileMenuContent: View {
    @Environment(DesktopViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MenuItemRow(title: "New Window",   icon: "square.and.pencil", shortcut: "⌘N") {
                if let id = vm.activeWindowId,
                   let win = vm.openWindows.first(where: { $0.id == id }) {
                    vm.openNewWindow(for: win.appType)
                }
                dismiss()
            }
            MenuItemRow(title: "Open…",        icon: "folder",            shortcut: "⌘O") { dismiss() }
            MenuItemRow(title: "Close Window", icon: "xmark.square",      shortcut: "⌘W") {
                if let id = vm.activeWindowId { vm.closeWindow(id) }
                dismiss()
            }
        }
        .frame(width: 220)
        .padding(.vertical, 4)
    }
}

// MARK: - Edit Menu
struct EditMenuContent: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MenuItemRow(title: "Undo",  icon: "arrow.uturn.backward", shortcut: "⌘Z") { dismiss() }
            MenuItemRow(title: "Redo",  icon: "arrow.uturn.forward",  shortcut: "⌘Y") { dismiss() }
            Divider()
            MenuItemRow(title: "Copy",  icon: "doc.on.doc",           shortcut: "⌘C") { dismiss() }
            MenuItemRow(title: "Paste", icon: "clipboard",             shortcut: "⌘V") { dismiss() }
        }
        .frame(width: 220)
        .padding(.vertical, 4)
    }
}

// MARK: - View Menu
struct ViewMenuContent: View {
    @Environment(DesktopViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MenuItemRow(
                title: vm.isDockVisible ? "Hide Dock" : "Show Dock",
                icon: "dock.rectangle"
            ) {
                vm.toggleDock()
                dismiss()
            }
            MenuItemRow(title: "Enter Full Screen", icon: "arrow.up.left.and.arrow.down.right", shortcut: "⌘F") {
                dismiss()
            }
        }
        .frame(width: 220)
        .padding(.vertical, 4)
    }
}

// MARK: - Shared Menu Item Row
struct MenuItemRow: View {
    let title: String
    let icon: String
    var shortcut: String = ""
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.system(size: 13))
                Spacer()
                if !shortcut.isEmpty {
                    Text(shortcut)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isHovered ? Color.accentColor : Color.clear)
            .foregroundStyle(isHovered ? .white : .primary)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
