import SwiftUI

struct FileBrowserRootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if let cid = appState.selectedConversationID {
            FileBrowserView(conversationID: cid)
        } else {
            ContentUnavailableView("No conversation selected",
                                   systemImage: "paperclip",
                                   description: Text("Select a conversation to manage files."))
        }
    }
}
