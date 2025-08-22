import Foundation
import SQLite3

final class KelaDB {
    static let shared = KelaDB()
    private var db: OpaquePointer?

    private init() {
        open()
        createTables()
    }

    private func open() {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Kela.db")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if sqlite3_open(url.path, &db) != SQLITE_OK { }
    }

    private func createTables() {
        let createEvent = "CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY, type TEXT, text TEXT, app TEXT, ts REAL);"
        let createEmb = "CREATE TABLE IF NOT EXISTS embeddings (id INTEGER PRIMARY KEY, text TEXT, tags TEXT, vec BLOB);"
        _ = execute(sql: createEvent)
        _ = execute(sql: createEmb)
    }

    @discardableResult
    func execute(sql: String, bind: ((OpaquePointer?) -> Void)? = nil) -> Bool {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        bind?(stmt)
        defer { sqlite3_finalize(stmt) }
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func query(sql: String, bind: ((OpaquePointer?) -> Void)? = nil, map: (OpaquePointer?) -> Void) {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        bind?(stmt)
        defer { sqlite3_finalize(stmt) }
        while sqlite3_step(stmt) == SQLITE_ROW { map(stmt) }
    }
}


