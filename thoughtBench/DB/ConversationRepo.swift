import Foundation
import SQLite3

final class ConversationRepo {
    private unowned let db: SQLiteDatabase
    init(db: SQLiteDatabase) { self.db = db }

    func count() throws -> Int {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            if sqlite3_prepare_v2(handle, "SELECT COUNT(*) FROM conversations;", -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
            if sqlite3_step(stmt) == SQLITE_ROW {
                return Int(sqlite3_column_int(stmt, 0))
            }
            return 0
        }
    }

    func list() throws -> [Conversation] {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = "SELECT id, title, created_at, updated_at FROM conversations ORDER BY updated_at DESC;"
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            var out: [Conversation] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2))
                let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
                out.append(Conversation(id: id, title: title, createdAt: createdAt, updatedAt: updatedAt))
            }
            return out
        }
    }

    func insert(_ convo: Conversation) throws {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = "INSERT INTO conversations (id, title, created_at, updated_at) VALUES (?, ?, ?, ?);"
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, convo.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, convo.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(stmt, 3, convo.createdAt.timeIntervalSince1970)
            sqlite3_bind_double(stmt, 4, convo.updatedAt.timeIntervalSince1970)

            if sqlite3_step(stmt) != SQLITE_DONE {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
        }
    }

    func rename(id: String, title: String) throws {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = "UPDATE conversations SET title = ?, updated_at = ? WHERE id = ?;"
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(stmt, 2, Date().timeIntervalSince1970)
            sqlite3_bind_text(stmt, 3, id, -1, SQLITE_TRANSIENT)

            if sqlite3_step(stmt) != SQLITE_DONE {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
        }
    }

    func touch(id: String) throws {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = "UPDATE conversations SET updated_at = ? WHERE id = ?;"
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_double(stmt, 1, Date().timeIntervalSince1970)
            sqlite3_bind_text(stmt, 2, id, -1, SQLITE_TRANSIENT)

            if sqlite3_step(stmt) != SQLITE_DONE {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
        }
    }

    func delete(id: String) throws {
        try db.withDB { handle in
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            let sql = "DELETE FROM conversations WHERE id = ?;"
            if sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) != SQLITE_OK {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }

            sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT)
            if sqlite3_step(stmt) != SQLITE_DONE {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(handle)))
            }
        }
    }
}
