import Foundation
import SQLite3

enum EventType: String { case ocr, reply, transcript }

final class EventLog {
    func log(type: EventType, text: String, app: String) {
        let sql = "INSERT INTO events(type, text, app, ts) VALUES(?,?,?,?);"
        _ = KelaDB.shared.execute(sql: sql) { stmt in
            sqlite3_bind_text(stmt, 1, type.rawValue, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, text, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, app, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(stmt, 4, Date().timeIntervalSince1970)
        }
    }

    func recentSummaries(limit: Int) -> [String] {
        var results: [String] = []
        let sql = "SELECT type, substr(text,1,120) FROM events ORDER BY ts DESC LIMIT ?;"
        KelaDB.shared.query(sql: sql) { stmt in
            sqlite3_bind_int(stmt, 1, Int32(limit))
        } map: { stmt in
            if let typeC = sqlite3_column_text(stmt, 0), let textC = sqlite3_column_text(stmt, 1) {
                let type = String(cString: typeC)
                let text = String(cString: textC)
                results.append("[\(type)] \(text)")
            }
        }
        return results
    }
}

