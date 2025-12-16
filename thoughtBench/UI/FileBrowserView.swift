import SwiftUI
import UniformTypeIdentifiers

struct FileBrowserView: View {
    @EnvironmentObject var appState: AppState
    let conversationID: String

    @State private var attachments: [Attachment] = []
    @State private var isImporting = false
    @State private var importError: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if attachments.isEmpty {
                ContentUnavailableView("No files yet",
                                       systemImage: "paperclip",
                                       description: Text("Import PDFs, images, docs, spreadsheets, JSON, CSV, etc."))
                    .padding()
            } else {
                List {
                    ForEach(attachments) { att in
                        HStack(spacing: 10) {
                            Image(systemName: icon(for: att))
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(att.originalFilename)
                                    .lineLimit(1)
                                Text("\(att.mimeType) • \(ByteCountFormatter.string(fromByteCount: att.fileSize, countStyle: .file))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                let url = appState.fileStore.url(for: att)
                                #if os(macOS)
                                NSWorkspace.shared.open(url)
                                #else
                                // On iPad, rely on the share sheet later (MVP-2). For now, do nothing.
                                #endif
                            } label: {
                                Label("Open", systemImage: "arrow.up.right.square")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .task { await load() }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: allowedTypes(),
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task { await importFiles(urls) }
            case .failure(let err):
                importError = err.localizedDescription
            }
        }
        .alert("Import Error", isPresented: Binding(get: { importError != nil }, set: { _ in importError = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "")
        }
    }

    private var header: some View {
        HStack {
            Text("Files")
                .font(.headline)
            Spacer()
            Button {
                isImporting = true
            } label: {
                Label("Import", systemImage: "square.and.arrow.down")
            }
        }
        .padding()
    }

    private func load() async {
        do {
            attachments = try appState.db.attachments.list(conversationID: conversationID)
        } catch {
            print("Load attachments failed: \(error)")
            attachments = []
        }
    }

    private func importFiles(_ urls: [URL]) async {
        do {
            for url in urls {
                // Security-scoped access for iOS/iPadOS
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }

                let att = try appState.fileStore.importFile(from: url, conversationID: conversationID, messageID: nil)
                try appState.db.attachments.insert(att)
            }
            await load()
        } catch {
            importError = String(describing: error)
        }
    }

    private func icon(for att: Attachment) -> String {
        if att.mimeType.contains("pdf") { return "doc.richtext" }
        if att.mimeType.contains("image") { return "photo" }
        if att.mimeType.contains("spreadsheet") { return "tablecells" }
        if att.mimeType.contains("word") { return "doc.text" }
        if att.mimeType.contains("json") { return "curlybraces" }
        if att.mimeType.contains("csv") { return "table" }
        return "doc"
    }

    private func allowedTypes() -> [UTType] {
        // Broad list; users can import almost anything.
        var types: [UTType] = [
            .pdf, .plainText, .text, .rtf,
            .json, .commaSeparatedText,
            .png, .jpeg, .gif, .tiff, .heic,
            .zip, .data
        ]

        // Office formats (best-effort UTType identifiers)
        if let docx = UTType(filenameExtension: "docx") { types.append(docx) }
        if let xlsx = UTType(filenameExtension: "xlsx") { types.append(xlsx) }
        if let xlsm = UTType(filenameExtension: "xlsm") { types.append(xlsm) }
        if let xls = UTType(filenameExtension: "xls") { types.append(xls) }

        return Array(Set(types))
    }
}
