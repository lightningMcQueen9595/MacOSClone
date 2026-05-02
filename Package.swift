// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacOSClone",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacOSClone", targets: ["MacOSClone"])
    ],
    targets: [
        .executableTarget(
            name: "MacOSClone",
            path: ".",
            sources: [
                "MacOSCloneApp.swift",
                "Views/ContentView.swift",
                "Models/AppItem.swift",
                "Models/WindowItem.swift",
                "ViewModels/DesktopViewModel.swift",
                "Views/DockView.swift",
                "Views/MenuBarView.swift",
                "Views/WindowView.swift",
                "Views/Apps/CalculatorAppView.swift",
                "Views/Apps/NotesAppView.swift",
                "Views/Apps/WeatherAppView.swift",
                "Views/Apps/FinderAppView.swift"
            ]
        )
    ]
)
