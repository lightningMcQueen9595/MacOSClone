import SwiftUI
import Observation

@Observable
final class DesktopViewModel {

    // MARK: - Dock
    var dockItems: [AppItem] = [
        AppItem(appType: .finder),
        AppItem(appType: .safari),
        AppItem(appType: .messages),
        AppItem(appType: .appStore),
        AppItem(appType: .notes),
        AppItem(appType: .calculator),
        AppItem(appType: .weather),
        AppItem(appType: .trash)
    ]

    // MARK: - Windows
    var openWindows: [WindowItem] = []
    var activeWindowId: UUID? = nil
    private var nextZIndex: Double = 1.0

    // MARK: - Dock visibility
    var isDockVisible: Bool = true

    // MARK: - Trash
    var trashItemCount: Int = 0
    var trashIsEmpty: Bool { trashItemCount == 0 }

    // MARK: - Wallpaper
    var currentWallpaper: WallpaperType {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<8:   return .sunrise
        case 8..<12:  return .morning
        case 12..<17: return .afternoon
        case 17..<20: return .sunset
        case 20..<22: return .dusk
        default:      return .night
        }
    }

    // MARK: - Menu State
    var activeMenuApp: AppType? = nil

    // MARK: - Open / Close Windows
    func openApp(_ appType: AppType) {
        // Trash — no window, just increment
        if appType == .trash {
            addToTrash()
            return
        }
        // Bring existing window to front
        if let idx = openWindows.firstIndex(where: { $0.appType == appType }) {
            bringToFront(openWindows[idx].id)
            if openWindows[idx].state == .minimized {
                openWindows[idx].state = .normal
            }
            return
        }
        // Calculate staggered spawn position
        let offset = Double(openWindows.count) * 30
        let spawnX = 160 + offset
        let spawnY = 80 + offset
        nextZIndex += 1
        let window = WindowItem(appType: appType, position: CGPoint(x: spawnX, y: spawnY), zIndex: nextZIndex)
        openWindows.append(window)
        activeWindowId = window.id
        // Mark open in dock
        if let idx = dockItems.firstIndex(where: { $0.appType == appType }) {
            dockItems[idx].isOpen = true
            dockItems[idx].isBouncing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.dockItems[idx].isBouncing = false
            }
        }
        HapticManager.shared.impact(.light)
    }

    func closeWindow(_ id: UUID) {
        guard let idx = openWindows.firstIndex(where: { $0.id == id }) else { return }
        let appType = openWindows[idx].appType
        openWindows.remove(at: idx)
        // Update dock open state
        if !openWindows.contains(where: { $0.appType == appType }) {
            if let dIdx = dockItems.firstIndex(where: { $0.appType == appType }) {
                dockItems[dIdx].isOpen = false
            }
        }
        HapticManager.shared.impact(.medium)
    }

    func minimizeWindow(_ id: UUID) {
        guard let idx = openWindows.firstIndex(where: { $0.id == id }) else { return }
        openWindows[idx].state = .minimized
        HapticManager.shared.impact(.light)
    }

    func toggleMaximize(_ id: UUID) {
        guard let idx = openWindows.firstIndex(where: { $0.id == id }) else { return }
        openWindows[idx].state = openWindows[idx].state == .maximized ? .normal : .maximized
        HapticManager.shared.impact(.light)
    }

    func bringToFront(_ id: UUID) {
        guard let idx = openWindows.firstIndex(where: { $0.id == id }) else { return }
        nextZIndex += 1
        openWindows[idx].zIndex = nextZIndex
        activeWindowId = id
    }

    func updatePosition(_ id: UUID, position: CGPoint) {
        guard let idx = openWindows.firstIndex(where: { $0.id == id }) else { return }
        openWindows[idx].position = position
    }

    // MARK: - Dock Reorder
    func moveDockItem(from source: IndexSet, to destination: Int) {
        dockItems.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Trash
    func addToTrash() {
        trashItemCount += 1
        if trashItemCount >= 5 {
            emptyTrash()
        }
    }

    func emptyTrash() {
        trashItemCount = 0
        HapticManager.shared.notification(.success)
    }

    // MARK: - Dock Toggle
    func toggleDock() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isDockVisible.toggle()
        }
    }

    // MARK: - New Window
    func openNewWindow(for appType: AppType) {
        let offset = Double(openWindows.count) * 30
        nextZIndex += 1
        let window = WindowItem(
            appType: appType,
            position: CGPoint(x: 160 + offset, y: 80 + offset),
            zIndex: nextZIndex
        )
        openWindows.append(window)
        activeWindowId = window.id
    }
}

// MARK: - Wallpaper Type
enum WallpaperType {
    case sunrise, morning, afternoon, sunset, dusk, night

    var colors: [Color] {
        switch self {
        case .sunrise:
            return [Color(red: 0.98, green: 0.56, blue: 0.25),
                    Color(red: 0.95, green: 0.78, blue: 0.40),
                    Color(red: 0.55, green: 0.72, blue: 0.95)]
        case .morning:
            return [Color(red: 0.40, green: 0.68, blue: 0.98),
                    Color(red: 0.62, green: 0.83, blue: 0.99),
                    Color(red: 0.85, green: 0.93, blue: 1.00)]
        case .afternoon:
            return [Color(red: 0.10, green: 0.45, blue: 0.88),
                    Color(red: 0.30, green: 0.62, blue: 0.95),
                    Color(red: 0.60, green: 0.82, blue: 0.99)]
        case .sunset:
            return [Color(red: 0.92, green: 0.38, blue: 0.18),
                    Color(red: 0.85, green: 0.25, blue: 0.45),
                    Color(red: 0.38, green: 0.15, blue: 0.60)]
        case .dusk:
            return [Color(red: 0.18, green: 0.12, blue: 0.42),
                    Color(red: 0.35, green: 0.18, blue: 0.58),
                    Color(red: 0.60, green: 0.35, blue: 0.70)]
        case .night:
            return [Color(red: 0.02, green: 0.02, blue: 0.10),
                    Color(red: 0.05, green: 0.08, blue: 0.25),
                    Color(red: 0.10, green: 0.15, blue: 0.38)]
        }
    }

    var label: String {
        switch self {
        case .sunrise:   return "Sunrise"
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .sunset:    return "Sunset"
        case .dusk:      return "Dusk"
        case .night:     return "Night"
        }
    }
}

// MARK: - Haptic Manager
final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
