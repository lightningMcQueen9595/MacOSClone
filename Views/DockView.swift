import SwiftUI

struct DockView: View {
    @Environment(DesktopViewModel.self) private var vm
    @State private var hoveredId: UUID? = nil
    @State private var draggedId: UUID? = nil

    private let iconSize: CGFloat    = 56
    private let maxMagnify: CGFloat  = 84
    private let magnifyRange: CGFloat = 100

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(vm.dockItems) { item in
                DockIconView(
                    item: item,
                    iconSize: iconSize,
                    maxMagnify: maxMagnify,
                    hoveredId: $hoveredId,
                    draggedId: $draggedId
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
        }
    }
}

// MARK: - Single Dock Icon
struct DockIconView: View {
    @Environment(DesktopViewModel.self) private var vm

    let item: AppItem
    let iconSize: CGFloat
    let maxMagnify: CGFloat
    @Binding var hoveredId: UUID?
    @Binding var draggedId: UUID?

    @State private var showContextMenu = false

    // Magnification based on hover proximity
    private var magnifiedSize: CGFloat {
        guard hoveredId != nil else { return iconSize }
        if hoveredId == item.id { return maxMagnify }
        // No neighbor info here, keep simple
        return iconSize
    }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                RoundedRectangle(cornerRadius: magnifiedSize * 0.22, style: .continuous)
                    .fill(item.appType.iconColor)
                    .frame(width: magnifiedSize, height: magnifiedSize)

                Image(systemName: item.appType.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: magnifiedSize * 0.5, height: magnifiedSize * 0.5)
                    .foregroundStyle(.white)
            }
            .scaleEffect(item.isBouncing ? 1.2 : 1.0)
            .animation(
                item.isBouncing
                    ? .interpolatingSpring(stiffness: 300, damping: 8).repeatCount(3, autoreverses: true)
                    : .spring(response: 0.25, dampingFraction: 0.6),
                value: item.isBouncing
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: magnifiedSize)

            // Open indicator dot
            Circle()
                .fill(item.isOpen ? Color.primary.opacity(0.7) : Color.clear)
                .frame(width: 4, height: 4)
        }
        .onHover { hov in
            withAnimation(.spring(response: 0.2)) {
                hoveredId = hov ? item.id : nil
            }
        }
        .onTapGesture {
            vm.openApp(item.appType)
        }
        .contextMenu {
            DockContextMenu(item: item)
        }
        .draggable(item.appType.rawValue) // simple drag identifier
    }
}

// MARK: - Dock Context Menu
struct DockContextMenu: View {
    @Environment(DesktopViewModel.self) private var vm
    let item: AppItem

    var body: some View {
        Group {
            if item.appType == .trash {
                Button("Empty Trash") { vm.emptyTrash() }
                    .disabled(vm.trashIsEmpty)
                Text("Items: \(vm.trashItemCount)")
            } else {
                Button("Open \(item.appType.rawValue)") {
                    vm.openApp(item.appType)
                }
                if item.isOpen {
                    Button("Hide") {
                        if let win = vm.openWindows.first(where: { $0.appType == item.appType }) {
                            vm.minimizeWindow(win.id)
                        }
                    }
                    Button("Quit") {
                        if let win = vm.openWindows.first(where: { $0.appType == item.appType }) {
                            vm.closeWindow(win.id)
                        }
                    }
                }
            }
        }
    }
}
