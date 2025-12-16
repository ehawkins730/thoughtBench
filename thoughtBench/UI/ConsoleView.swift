import SwiftUI

struct ConsoleView: View {
    @State private var text = "Console (MVP-1)\n\nNext we’ll add:\n• Code preview panes (HTML/JS, Swift, Python)\n• Run logs from the model runner\n• Exportable artifacts\n"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Console")
                    .font(.headline)
                Spacer()
                Button {
                    text = ""
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            }
            .padding()

            Divider()

            ScrollView {
                Text(text.isEmpty ? "—" : text)
                    .textSelection(.enabled)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
}
