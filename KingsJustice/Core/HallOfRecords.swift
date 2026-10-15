import Foundation

/// Top-five run lists for Survival and Boss Rush, plus the best Daily Challenge scores.
enum HallOfRecords {
    static let limit = 5

    /// Adds a finished run to a highest-first top list. Returns its place (1 = best) if it made the list, otherwise nil.
    /// A run of zero never counts, and a tie ranks below the runs that got there first.
    @discardableResult
    static func insert(_ list: inout [Int], value: Int, limit: Int = HallOfRecords.limit) -> Int? {
        guard value > 0 else { return nil }
        let place = list.firstIndex(where: { value > $0 }) ?? list.count
        guard place < limit else { return nil }
        list.insert(value, at: place)
        if list.count > limit { list.removeLast(list.count - limit) }
        return place + 1
    }

    /// The best Daily Challenge scores across all days, highest first (newer day wins a tie).
    static func topDaily(_ bestDaily: [String: Int], count: Int = 3) -> [(date: String, score: Int)] {
        let sorted = bestDaily.filter { $0.value > 0 }
            .sorted { a, b in a.value != b.value ? a.value > b.value : a.key > b.key }
        return sorted.prefix(count).map { (date: $0.key, score: $0.value) }
    }
}
