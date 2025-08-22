import Foundation

final class Throttle {
    private let interval: TimeInterval
    private var last: Date = .distantPast
    init(interval: TimeInterval) { self.interval = interval }
    func execute(_ block: @escaping () -> Void) {
        let now = Date()
        guard now.timeIntervalSince(last) >= interval else { return }
        last = now
        block()
    }
}


