import Foundation

/// Maps a calendar date to a shloka index **purely** from the date, so the app, widget, and
/// notification always agree and the chosen shloka is stable for the whole day (impl plan §6,
/// PRD §5.1). No randomness, no stored state.
///
/// Phase 0: `total` is a stubbed sample count and the resolved shloka is placeholder text. The
/// function and its tests exist before the real 700 shlokas do.
public struct DailyShlokaService: Sendable {
    private let calendar: Calendar

    /// Inject a calendar in tests for determinism; production uses the device's current calendar.
    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Day-of-year (1...366) mapped into `0..<total`. Pure function of the date.
    public func shlokaIndex(for date: Date, total: Int) -> Int {
        precondition(total > 0, "total must be positive")
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return (day - 1) % total
    }

    /// Resolves the day's shloka from a content list. Empty list returns nil (Phase 0 guard).
    public func dailyShloka(for date: Date, in shlokas: [Shloka]) -> Shloka? {
        guard !shlokas.isEmpty else { return nil }
        return shlokas[shlokaIndex(for: date, total: shlokas.count)]
    }

    /// A stable per-day key ("yyyy-MM-dd" in the given calendar), used to tag the App Group payload
    /// and to know when the widget timeline should roll over (local midnight).
    public func dayKey(for date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// Start of the next local day — the widget's timeline reload point (impl plan §6, pages W1).
    public func nextMidnight(after date: Date) -> Date {
        let startOfToday = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date.addingTimeInterval(86_400)
    }
}
