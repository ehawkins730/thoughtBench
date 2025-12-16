import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selection: SidebarTab = .chat

    enum SidebarTab: String, CaseIterable, Identifiable {
        case chat = "Chat"
        case files = "Files"
        case console = "Console"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            switch selection {
            case .chat:
                ChatRootView()
            case .files:
                FileBrowserRootView()
            case .console:
                ConsoleView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
