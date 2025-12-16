import Foundation
import SQLite3

/// A tiny SQLite wrapper with:
/// - one shared connection (serialized via a queue)
/// - basic error handling
/// - schema + repos
///
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
final class SQLiteDatabase {
    static let shared = SQLiteDatabase()

    private let queue = DispatchQueue(label: "thoughtBench.sqlite.queue")
    private var db: OpaquePointer?

    lazy var conversations: ConversationRepo = ConversationRepo(db: self)
    lazy var messages: MessageRepo = MessageRepo(db: self)
    lazy var attachments: AttachmentRepo = AttachmentRepo(db: self)

    private init() {
        let path = SQLiteDatabase.databasePath()
        FileManager.default.createDirectoryIfNeeded(at: (path as NSString).deletingLastPathComponent)

        var handle: OpaquePointer?
        if sqlite3_open_v2(path, &handle, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
            let msg = String(cString: sqlite3_errmsg(handle))
            sqlite3_close(handle)
            fatalError("Unable to open DB: \(msg)")
        }
        self.db = handle

        if let db = self.db {
            var errMsg: UnsafeMutablePointer<Int8>?
            let pragmas = [
                "PRAGMA journal_mode=WAL;",
                "PRAGMA synchronous=NORMAL;",
                "PRAGMA foreign_keys=ON;"
            ]
            for sql in pragmas {
                let rc = sqlite3_exec(db, sql, nil, nil, &errMsg)
                if rc != SQLITE_OK {
                    let msg = errMsg.map { String(cString: $0) } ?? "Unknown SQLite error"
                    sqlite3_free(errMsg)
                    print("SQLite exec error: \(msg)\nSQL: \(sql)")
                }
            }
        }

        do { try migrateIfNeeded() }
        catch { fatalError("DB migration failed: \(error)") }
    }

    deinit {
        if let db { sqlite3_close(db) }
    }

    static func databasePath() -> String {
        let appSupport = FileManager.default.applicationSupportDirectory(appName: "thoughtBench")
        return (appSupport as NSString).appendingPathComponent("thoughtBench.sqlite")
    }

    func withDB<T>(_ work: (OpaquePointer) throws -> T) rethrows -> T {
        try queue.sync {
            guard let db else { throw SQLiteError(message: "DB is not open") }
            return try work(db)
        }
    }

    @discardableResult
    func exec(_ sql: String) -> Bool {
        queue.sync {
            guard let db else { return false }
            var errMsg: UnsafeMutablePointer<Int8>?
            let rc = sqlite3_exec(db, sql, nil, nil, &errMsg)
            if rc != SQLITE_OK {
                let msg = errMsg.map { String(cString: $0) } ?? "Unknown SQLite error"
                sqlite3_free(errMsg)
                print("SQLite exec error: \(msg)\nSQL: \(sql)")
                return false
            }
            return true
        }
    }

    private func migrateIfNeeded() throws {
        // v1 schema
        try withDB { db in
            let schemaSQL = """
            CREATE TABLE IF NOT EXISTS conversations (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              created_at REAL NOT NULL,
              updated_at REAL NOT NULL
            );

            CREATE TABLE IF NOT EXISTS messages (
              id TEXT PRIMARY KEY,
              conversation_id TEXT NOT NULL,
              role TEXT NOT NULL,
              content TEXT NOT NULL,
              created_at REAL NOT NULL,
              FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
            );

            CREATE INDEX IF NOT EXISTS idx_messages_conversation_time
              ON messages(conversation_id, created_at);

            CREATE TABLE IF NOT EXISTS attachments (
              id TEXT PRIMARY KEY,
              conversation_id TEXT NOT NULL,
              message_id TEXT,
              original_filename TEXT NOT NULL,
              stored_filename TEXT NOT NULL,
              mime_type TEXT NOT NULL,
              file_size INTEGER NOT NULL,
              sha256 TEXT NOT NULL,
              created_at REAL NOT NULL,
              FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
              FOREIGN KEY(message_id) REFERENCES messages(id) ON DELETE SET NULL
            );

            CREATE INDEX IF NOT EXISTS idx_attachments_conversation_time
              ON attachments(conversation_id, created_at);
            """
            var errMsg: UnsafeMutablePointer<Int8>?
            let rc = sqlite3_exec(db, schemaSQL, nil, nil, &errMsg)
            if rc != SQLITE_OK {
                let msg = errMsg.map { String(cString: $0) } ?? "Unknown SQLite error"
                sqlite3_free(errMsg)
                throw SQLiteError(message: msg)
            }
        }

        // Ensure at least one default conversation so UI isn't empty
        if (try conversations.count()) == 0 {
            let defaultConvo = Conversation(
                id: UUID().uuidString,
                title: "Welcome",
                createdAt: Date(),
                updatedAt: Date()
            )
            try conversations.insert(defaultConvo)
        }
    }
}

struct SQLiteError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

// MARK: - Helpers

extension FileManager {
    func applicationSupportDirectory(appName: String) -> String {
        let base = urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent(appName, isDirectory: true)
        createDirectoryIfNeeded(at: dir.path)
        return dir.path
    }

    func createDirectoryIfNeeded(at path: String) {
        var isDir: ObjCBool = false
        if fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue { return }
        }
        try? createDirectory(atPath: path, withIntermediateDirectories: true)
    }
}
