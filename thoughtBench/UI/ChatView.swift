import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    let conversationID: String

    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isSending: Bool = false
    @State private var showingPromptEditor = false
    @State private var draftPrompt = ""

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { msg in
                            MessageRow(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            composer
        }
        .task { await load() }
        .onChange(of: conversationID) { _, _ in
            Task { await load() }
        }
        .sheet(isPresented: $showingPromptEditor) {
            PromptEditorView(text: $draftPrompt) {
                showingPromptEditor = false
            } onSubmit: {
                showingPromptEditor = false
                inputText = draftPrompt
                Task { await send() }
            }
        }
    }

    private var header: some View {
        HStack {
            Text(currentTitle())
                .font(.headline)
                .lineLimit(1)
            Spacer()
            Button {
                draftPrompt = inputText
                showingPromptEditor = true
            } label: {
                Label("Edit Prompt", systemImage: "pencil")
            }
            .keyboardShortcut("e", modifiers: [.command])
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var composer: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Message…", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...6)
                    .disabled(isSending)

                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSending || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            HStack {
                Text("Offline LLM wiring is next. Right now we persist chats + files.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
    }

    private func load() async {
        do {
            messages = try appState.db.messages.list(conversationID: conversationID)
        } catch {
            print("Load messages failed: \(error)")
            messages = []
        }
    }

    private func send() async {
        let prompt = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        isSending = true
        defer { isSending = false }

        do {
            let userMsg = Message(
                id: UUID().uuidString,
                conversationID: conversationID,
                role: .user,
                content: prompt,
                createdAt: Date()
            )
            try appState.db.messages.insert(userMsg)
            inputText = ""
            await load()

            // Placeholder assistant echo for MVP-1 (DB + UI)
            let assistant = Message(
                id: UUID().uuidString,
                conversationID: conversationID,
                role: .assistant,
                content: "✅ Saved. Next we’ll connect this to your offline model runner and stream tokens here.",
                createdAt: Date()
            )
            try appState.db.messages.insert(assistant)
            await load()

        } catch {
            print("Send failed: \(error)")
        }
    }

    private func currentTitle() -> String {
        appState.conversations.first(where: { $0.id == conversationID })?.title ?? "Chat"
    }
}
