import SwiftUI

// MARK: - App Identifier
enum AppType: String, CaseIterable, Identifiable {
    case finder = "Finder"
    case safari = "Safari"
    case messages = "Messages"
    case appStore = "App Store"
    case trash = "Trash"
    case calculator = "Calculator"
    case notes = "Notes"
    case weather = "Weather"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .finder:     return "folder.fill"
        case .safari:     return "safari"
        case .messages:   return "message.fill"
        case .appStore:   return "square.stack.3d.up.fill"
        case .trash:      return "trash.fill"
        case .calculator: return "plus.forwardslash.minus"
        case .notes:      return "note.text"
        case .weather:    return "cloud.sun.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .finder:     return Color(red: 0.17, green: 0.47, blue: 0.93)
        case .safari:     return Color(red: 0.22, green: 0.55, blue: 0.95)
        case .messages:   return Color(red: 0.22, green: 0.75, blue: 0.35)
        case .appStore:   return Color(red: 0.17, green: 0.47, blue: 0.93)
        case .trash:      return Color(red: 0.55, green: 0.55, blue: 0.60)
        case .calculator: return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .notes:      return Color(red: 0.98, green: 0.82, blue: 0.22)
        case .weather:    return Color(red: 0.17, green: 0.60, blue: 0.95)
        }
    }

    var defaultSize: CGSize {
        switch self {
        case .finder:     return CGSize(width: 600, height: 420)
        case .calculator: return CGSize(width: 280, height: 420)
        case .notes:      return CGSize(width: 500, height: 380)
        case .weather:    return CGSize(width: 380, height: 480)
        default:          return CGSize(width: 520, height: 380)
        }
    }
}

// MARK: - App Item (Dock Icon)
struct AppItem: Identifiable, Equatable {
    let id: UUID
    var appType: AppType
    var isOpen: Bool = false
    var isBouncing: Bool = false

    init(appType: AppType) {
        self.id = UUID()
        self.appType = appType
    }
}
