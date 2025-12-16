import SwiftUI

struct ChatRootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if let cid = appState.selectedConversationID {
            ChatView(conversationID: cid)
        } else {
            ContentUnavailableView("No conversation selected",
                                   systemImage: "bubble.left.and.bubble.right",
                                   description: Text("Create a new chat from the sidebar."))
        }
    }
}
