import SwiftUI

struct WindowView: View {
    @Environment(DesktopViewModel.self) private var vm
    let window: WindowItem
    let screenSize: CGSize

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private var effectivePosition: CGPoint {
        if window.state == .maximized {
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
        return window.position
    }

    private var effectiveSize: CGSize {
        if window.state == .maximized {
            return CGSize(width: screenSize.width, height: screenSize.height - 28)
        }
        return window.size
    }

    private var cornerRadius: CGFloat {
        window.state == .maximized ? 0 : 12
    }

    var body: some View {
        Group {
            if window.state != .minimized {
                VStack(spacing: 0) {
                    // Title Bar
                    TitleBarView(window: window)

                    // App Content
                    appContentView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                }
                .frame(width: effectiveSize.width, height: effectiveSize.height)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(.systemBackground).opacity(0.92))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(.secondary.opacity(0.3), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(isDragging ? 0.5 : 0.3),
                        radius: isDragging ? 30 : 16,
                        y: isDragging ? 16 : 8)
                .scaleEffect(isDragging ? 1.01 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: window.state)
                .position(effectivePosition)
                .offset(dragOffset)
                .zIndex(window.zIndex)
                .gesture(dragGesture)
                .onTapGesture { vm.bringToFront(window.id) }
            }
        }
    }

    // MARK: - App Router
    @ViewBuilder
    private var appContentView: some View {
        switch window.appType {
        case .calculator: CalculatorAppView()
        case .notes:      NotesAppView()
        case .weather:    WeatherAppView()
        case .finder:     FinderAppView()
        default:          PlaceholderAppView(appType: window.appType)
        }
    }

    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                guard window.state == .normal else { return }
                if !isDragging {
                    isDragging = true
                    vm.bringToFront(window.id)
                    HapticManager.shared.impact(.light)
                }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard window.state == .normal else { return }
                isDragging = false
                let newPos = CGPoint(
                    x: window.position.x + value.translation.width,
                    y: window.position.y + value.translation.height
                )
                // Clamp to screen bounds
                let halfW = effectiveSize.width / 2
                let halfH = effectiveSize.height / 2
                let clamped = CGPoint(
                    x: max(halfW, min(screenSize.width - halfW, newPos.x)),
                    y: max(halfH + 28, min(screenSize.height - halfH - 80, newPos.y))
                )
                vm.updatePosition(window.id, position: clamped)
                dragOffset = .zero
                HapticManager.shared.impact(.light)
            }
    }
}

// MARK: - Title Bar
struct TitleBarView: View {
    @Environment(DesktopViewModel.self) private var vm
    let window: WindowItem

    var body: some View {
        HStack(spacing: 8) {
            // Traffic light buttons
            TrafficLightButton(role: .close, color: Color(red: 1.0, green: 0.37, blue: 0.34)) {
                vm.closeWindow(window.id)
            }
            TrafficLightButton(role: .minimize, color: Color(red: 1.0, green: 0.73, blue: 0.22)) {
                vm.minimizeWindow(window.id)
            }
            TrafficLightButton(role: .maximize, color: Color(red: 0.27, green: 0.80, blue: 0.39)) {
                vm.toggleMaximize(window.id)
            }

            Spacer()

            Text(window.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary.opacity(0.85))

            Spacer()

            // Balance spacer (same width as 3 buttons + spacing)
            Color.clear.frame(width: 52, height: 12)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// MARK: - Traffic Light Button
enum TrafficLightRole {
    case close, minimize, maximize

    var iconName: String {
        switch self {
        case .close:    return "xmark"
        case .minimize: return "minus"
        case .maximize: return "plus"
        }
    }
}

struct TrafficLightButton: View {
    let role: TrafficLightRole
    let color: Color
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(isHovered ? color : color.opacity(0.85))
                .frame(width: 12, height: 12)
                .overlay {
                    if isHovered {
                        Image(systemName: role.iconName)
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Placeholder
struct PlaceholderAppView: View {
    let appType: AppType

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: appType.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundStyle(appType.iconColor)
            Text(appType.rawValue)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("This app is not yet implemented.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
