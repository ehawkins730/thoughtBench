import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    let db: SQLiteDatabase
    let fileStore: FileStore

    @Published var conversations: [Conversation] = []
    @Published var selectedConversationID: String? = nil

    init() {
        self.db = SQLiteDatabase.shared
        self.fileStore = FileStore.shared
        Task { await refreshConversations(selectFirstIfNeeded: true) }
    }

    func refreshConversations(selectFirstIfNeeded: Bool = false) async {
        do {
            conversations = try db.conversations.list()
            if selectFirstIfNeeded {
                if selectedConversationID == nil {
                    selectedConversationID = conversations.first?.id
                }
            }
        } catch {
            print("Failed to refresh conversations: \(error)")
        }
    }

    func selectConversation(_ id: String) {
        selectedConversationID = id
    }

    func createConversation(title: String = "New Chat") async {
        do {
            let convo = Conversation(id: UUID().uuidString, title: title, createdAt: Date(), updatedAt: Date())
            try db.conversations.insert(convo)
            await refreshConversations(selectFirstIfNeeded: false)
            selectedConversationID = convo.id
        } catch {
            print("Create conversation failed: \(error)")
        }
    }

    func renameConversation(id: String, title: String) async {
        do {
            try db.conversations.rename(id: id, title: title)
            await refreshConversations()
        } catch {
            print("Rename failed: \(error)")
        }
    }

    func deleteConversation(id: String) async {
        do {
            try db.conversations.delete(id: id)
            await refreshConversations()
            if selectedConversationID == id {
                selectedConversationID = conversations.first?.id
            }
        } catch {
            print("Delete failed: \(error)")
        }
    }
}
