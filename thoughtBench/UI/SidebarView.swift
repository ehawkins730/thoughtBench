import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selection: ContentView.SidebarTab

    @State private var showingNewChat = false
    @State private var newChatTitle = "New Chat"
    @State private var renamingID: String? = nil
    @State private var renameText: String = ""

    var body: some View {
        List(selection: $selection) {
            Section("Workspaces") {
                Label(ContentView.SidebarTab.chat.rawValue, systemImage: "bubble.left.and.bubble.right")
                    .tag(ContentView.SidebarTab.chat)
                Label(ContentView.SidebarTab.files.rawValue, systemImage: "paperclip")
                    .tag(ContentView.SidebarTab.files)
                Label(ContentView.SidebarTab.console.rawValue, systemImage: "terminal")
                    .tag(ContentView.SidebarTab.console)
            }

            Section("Conversations") {
                ForEach(appState.conversations) { convo in
                    HStack(spacing: 8) {
                        Image(systemName: appState.selectedConversationID == convo.id ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                            .foregroundStyle(appState.selectedConversationID == convo.id ? .green : .secondary)

                        if renamingID == convo.id {
                            TextField("Title", text: $renameText)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    Task { await appState.renameConversation(id: convo.id, title: renameText.trimmingCharacters(in: .whitespacesAndNewlines)) }
                                    renamingID = nil
                                }
                        } else {
                            Text(convo.title)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }

                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { appState.selectConversation(convo.id) }
                    .contextMenu {
                        Button("Rename") {
                            renamingID = convo.id
                            renameText = convo.title
                        }
                        Button(role: .destructive) {
                            Task { await appState.deleteConversation(id: convo.id) }
                        } label: { Text("Delete") }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewChat = true
                } label: {
                    Label("New Chat", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewChat) {
            NavigationStack {
                Form {
                    TextField("Title", text: $newChatTitle)
                }
                .navigationTitle("New Chat")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingNewChat = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            let t = newChatTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                            Task { await appState.createConversation(title: t.isEmpty ? "New Chat" : t) }
                            showingNewChat = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
