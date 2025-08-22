import Foundation

struct Ranker {
    func score(novelty: Double, usefulness: Double) -> Double {
        0.4 * novelty + 0.6 * usefulness
    }
}


