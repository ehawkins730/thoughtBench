import Foundation
import SQLite3

final class AttachmentRepo {
    private unowned let db: SQLiteDatabase
    init(db: SQLiteDatabase) { self.db = db }

    func list(conversationID: String) throws -> [Attachment] {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = """
            SELECT id, conversation_id, message_id, original_filename, stored_filename, mime_type, file_size, sha256, created_at
            FROM attachments
            WHERE conversation_id = ?
            ORDER BY created_at DESC;
            """
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, conversationID, -1, SQLITE_TRANSIENT)

            var out: [Attachment] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let cid = String(cString: sqlite3_column_text(stmt, 1))
                let midPtr = sqlite3_column_text(stmt, 2)
                let mid = midPtr != nil ? String(cString: midPtr!) : nil
                let original = String(cString: sqlite3_column_text(stmt, 3))
                let stored = String(cString: sqlite3_column_text(stmt, 4))
                let mime = String(cString: sqlite3_column_text(stmt, 5))
                let size = sqlite3_column_int64(stmt, 6)
                let sha = String(cString: sqlite3_column_text(stmt, 7))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 8))

                out.append(Attachment(
                    id: id,
                    conversationID: cid,
                    messageID: mid,
                    originalFilename: original,
                    storedFilename: stored,
                    mimeType: mime,
                    fileSize: size,
                    sha256: sha,
                    createdAt: createdAt
                ))
            }
            return out
        }
    }

    func insert(_ att: Attachment) throws {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = """
            INSERT INTO attachments
            (id, conversation_id, message_id, original_filename, stored_filename, mime_type, file_size, sha256, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
            """
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, att.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, att.conversationID, -1, SQLITE_TRANSIENT)
            if let mid = att.messageID {
                sqlite3_bind_text(stmt, 3, mid, -1, SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_null(stmt, 3)
            }
            sqlite3_bind_text(stmt, 4, att.originalFilename, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 5, att.storedFilename, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 6, att.mimeType, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(stmt, 7, att.fileSize)
            sqlite3_bind_text(stmt, 8, att.sha256, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(stmt, 9, att.createdAt.timeIntervalSince1970)

            if sqlite3_step(stmt) != SQLITE_DONE {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
        }

        try db.conversations.touch(id: att.conversationID)
    }
}
