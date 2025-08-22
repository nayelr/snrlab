import Foundation

final class TriggerGraph {
    private(set) var latestOCR: String = ""
    private var lastFiredAt: Date = .distantPast

    func ingest(ocrText: String) {
        latestOCR = ocrText
    }

    func latestOCRPrefix(max: Int) -> String { String(latestOCR.prefix(max)) }

    func shouldFireErrorSuggestion() -> Bool {
        let now = Date()
        guard now.timeIntervalSince(lastFiredAt) > 30 else { return false }
        let lower = latestOCR.lowercased()
        let match = lower.contains("error:") || lower.contains("exception") || lower.contains("stack trace")
        if match { lastFiredAt = now }
        return match
    }
}


