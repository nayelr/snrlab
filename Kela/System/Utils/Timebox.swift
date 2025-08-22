import Foundation

func timebox<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw NSError(domain: "Kela", code: -1, userInfo: [NSLocalizedDescriptionKey: "Timeout"]) }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}


