import SwiftUI

enum WindowState {
    case normal, minimized, maximized
}

struct WindowItem: Identifiable, Equatable {
    let id: UUID
    let appType: AppType
    var position: CGPoint
    var size: CGSize
    var state: WindowState = .normal
    var zIndex: Double
    var title: String

    init(appType: AppType, position: CGPoint, zIndex: Double = 1.0) {
        self.id = UUID()
        self.appType = appType
        self.position = position
        self.size = appType.defaultSize
        self.zIndex = zIndex
        self.title = appType.rawValue
    }
}
