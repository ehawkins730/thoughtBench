import SwiftUI

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            roleBadge
            VStack(alignment: .leading, spacing: 6) {
                Text(message.role.rawValue.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(message.content)
                    .textSelection(.enabled)
                    .font(.body)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var roleBadge: some View {
        Image(systemName: iconName)
            .foregroundStyle(iconColor)
            .font(.system(size: 18, weight: .semibold))
            .frame(width: 26)
            .padding(.top, 2)
    }

    private var iconName: String {
        switch message.role {
        case .system: return "gearshape.fill"
        case .user: return "person.fill"
        case .assistant: return "sparkles"
        }
    }

    private var iconColor: Color {
        switch message.role {
        case .system: return .secondary
        case .user: return .blue
        case .assistant: return .purple
        }
    }

    private var background: Color {
        switch message.role {
        case .system: return Color.secondary.opacity(0.10)
        case .user: return Color.blue.opacity(0.08)
        case .assistant: return Color.purple.opacity(0.08)
        }
    }
}
