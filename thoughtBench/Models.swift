import Foundation

struct Conversation: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
}

struct Message: Identifiable, Hashable, Codable {
    enum Role: String, Codable { case system, user, assistant }
    let id: String
    let conversationID: String
    let role: Role
    var content: String
    var createdAt: Date
}

struct Attachment: Identifiable, Hashable, Codable {
    let id: String
    let conversationID: String
    let messageID: String?
    let originalFilename: String
    let storedFilename: String
    let mimeType: String
    let fileSize: Int64
    let sha256: String
    let createdAt: Date
}
