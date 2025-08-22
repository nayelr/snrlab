import Foundation
import SQLite3

final class EmbeddingsStore {
    func remember(text: String, tags: [String]) {
        let vec = embed(text)
        let data = Data(bytes: vec, count: vec.count * MemoryLayout<Float>.size)
        let sql = "INSERT INTO embeddings(text, tags, vec) VALUES(?,?,?);"
        _ = KelaDB.shared.execute(sql: sql) { stmt in
            sqlite3_bind_text(stmt, 1, text, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, tags.joined(separator: ","), -1, SQLITE_TRANSIENT)
            _ = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                sqlite3_bind_blob(stmt, 3, ptr.baseAddress, Int32(data.count), SQLITE_TRANSIENT)
            }
        }
    }

    func recall(query: String, limit: Int) -> [(text: String, score: Float)] {
        let q = embed(query)
        var results: [(String, Float, [Float])] = []
        let sql = "SELECT text, vec FROM embeddings;"
        KelaDB.shared.query(sql: sql) { _ in } map: { stmt in
            if let textC = sqlite3_column_text(stmt, 0), let blob = sqlite3_column_blob(stmt, 1) {
                let text = String(cString: textC)
                let size = Int(sqlite3_column_bytes(stmt, 1)) / MemoryLayout<Float>.size
                let buffer = blob.bindMemory(to: Float.self, capacity: size)
                let arr = Array(UnsafeBufferPointer(start: buffer, count: size))
                let score = cosine(q, arr)
                results.append((text, score, arr))
            }
        }
        return results.sorted { $0.1 > $1.1 }.prefix(limit).map { ($0.0, $0.1) }
    }

    private func embed(_ text: String) -> [Float] {
        // Mock embedding: hash-based deterministic vector
        var rng = UInt64(abs(text.hashValue))
        var vec = [Float](repeating: 0, count: 64)
        for i in 0..<vec.count {
            rng = rng &* 2862933555777941757 &+ 3037000493
            vec[i] = Float(rng % 1000) / 1000.0
        }
        return vec
    }

    private func cosine(_ a: [Float], _ b: [Float]) -> Float {
        let n = min(a.count, b.count)
        var dot: Float = 0, aa: Float = 0, bb: Float = 0
        for i in 0..<n { dot += a[i]*b[i]; aa += a[i]*a[i]; bb += b[i]*b[i] }
        return dot / (sqrt(aa*bb) + 1e-6)
    }
}

