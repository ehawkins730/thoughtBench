import Foundation
import SQLite3

final class MessageRepo {
    private unowned let db: SQLiteDatabase
    init(db: SQLiteDatabase) { self.db = db }

    func list(conversationID: String) throws -> [Message] {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = """
            SELECT id, conversation_id, role, content, created_at
            FROM messages
            WHERE conversation_id = ?
            ORDER BY created_at ASC;
            """
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, conversationID, -1, SQLITE_TRANSIENT)

            var out: [Message] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let cid = String(cString: sqlite3_column_text(stmt, 1))
                let roleRaw = String(cString: sqlite3_column_text(stmt, 2))
                let content = String(cString: sqlite3_column_text(stmt, 3))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))
                let role = Message.Role(rawValue: roleRaw) ?? .user

                out.append(Message(id: id, conversationID: cid, role: role, content: content, createdAt: createdAt))
            }
            return out
        }
    }

    func insert(_ msg: Message) throws {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = "INSERT INTO messages (id, conversation_id, role, content, created_at) VALUES (?, ?, ?, ?, ?);"
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, msg.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, msg.conversationID, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, msg.role.rawValue, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 4, msg.content, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(stmt, 5, msg.createdAt.timeIntervalSince1970)

            if sqlite3_step(stmt) != SQLITE_DONE {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
        }

        try db.conversations.touch(id: msg.conversationID)
    }
}
