import Foundation
import UniformTypeIdentifiers
import CryptoKit

final class FileStore {
    static let shared = FileStore()
    private init() {}

    func baseDir() -> String {
        FileManager.default.applicationSupportDirectory(appName: "thoughtBench")
    }

    func filesDir(for conversationID: String) -> String {
        let dir = (baseDir() as NSString).appendingPathComponent("Files/\(conversationID)")
        FileManager.default.createDirectoryIfNeeded(at: dir)
        return dir
    }

    /// Copies a file into app storage and returns metadata suitable for Attachment.
    func importFile(from sourceURL: URL, conversationID: String, messageID: String?) throws -> Attachment {
        let fm = FileManager.default
        let data = try Data(contentsOf: sourceURL)
        let sha = sha256Hex(data)
        let size = Int64(data.count)
        let originalName = sourceURL.lastPathComponent

        let storedName = "\(UUID().uuidString)_\(originalName)"
        let dest = URL(fileURLWithPath: filesDir(for: conversationID)).appendingPathComponent(storedName)

        // Write atomically
        try data.write(to: dest, options: [.atomic])

        let mime = mimeType(for: sourceURL)

        return Attachment(
            id: UUID().uuidString,
            conversationID: conversationID,
            messageID: messageID,
            originalFilename: originalName,
            storedFilename: storedName,
            mimeType: mime,
            fileSize: size,
            sha256: sha,
            createdAt: Date()
        )
    }

    func url(for attachment: Attachment) -> URL {
        URL(fileURLWithPath: filesDir(for: attachment.conversationID))
            .appendingPathComponent(attachment.storedFilename)
    }

    private func sha256Hex(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func mimeType(for url: URL) -> String {
        if let type = UTType(filenameExtension: url.pathExtension),
           let mime = type.preferredMIMEType {
            return mime
        }
        return "application/octet-stream"
    }
}
