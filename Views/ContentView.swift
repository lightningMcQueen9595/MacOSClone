import SwiftUI

struct ContentView: View {
    @Environment(DesktopViewModel.self) private var vm
    @State private var now = Date()

    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {

                // MARK: - Dynamic Wallpaper
                WallpaperView(wallpaper: vm.currentWallpaper)
                    .ignoresSafeArea()

                // MARK: - Open Windows (sorted by zIndex)
                ForEach(vm.openWindows.sorted(by: { $0.zIndex < $1.zIndex })) { window in
                    WindowView(window: window, screenSize: geo.size)
                }

                // MARK: - Menu Bar
                MenuBarView(screenSize: geo.size)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)

                // MARK: - Dock
                if vm.isDockVisible {
                    VStack {
                        Spacer()
                        DockView()
                            .padding(.bottom, 8)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onReceive(timer) { _ in
            now = Date()
        }
    }
}

// MARK: - Wallpaper View
struct WallpaperView: View {
    let wallpaper: WallpaperType
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: wallpaper.colors,
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)

            // Subtle bokeh orbs
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(wallpaper.colors[i % wallpaper.colors.count].opacity(0.18))
                    .frame(width: CGFloat(120 + i * 60), height: CGFloat(120 + i * 60))
                    .offset(
                        x: CGFloat([-100, 150, -80, 200, -50][i]),
                        y: CGFloat([100, -80, 250, 40, 300][i])
                    )
                    .blur(radius: 40)
                    .animation(
                        .easeInOut(duration: Double(6 + i * 2)).repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
