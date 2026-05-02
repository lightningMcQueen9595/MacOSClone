import SwiftUI

@main
struct MacOSCloneApp: App {
    @State private var desktopVM = DesktopViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(desktopVM)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
