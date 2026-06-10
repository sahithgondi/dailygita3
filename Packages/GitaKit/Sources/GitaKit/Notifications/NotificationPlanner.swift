import Foundation

/// One scheduled daily-reminder notification, fully resolved but framework-free so it can be built
/// and unit-tested without `UserNotifications` or entitlements. The app's `NotificationScheduler`
/// turns each of these into a `UNNotificationRequest`.
public struct PlannedNotification: Equatable, Sendable {
    /// Stable request id, e.g. "daily-2026-06-11" (one per calendar day).
    public let id: String
    /// When it fires — calendar components (year/month/day/hour/minute) for a one-shot trigger.
    public let fireDate: DateComponents
    public let title: String
    public let body: String
    /// Carried in `userInfo` for tap-through (the day's shloka).
    public let shlokaID: String
    public let chapter: Int

    public init(id: String, fireDate: DateComponents, title: String, body: String,
                shlokaID: String, chapter: Int) {
        self.id = id
        self.fireDate = fireDate
        self.title = title
        self.body = body
        self.shlokaID = shlokaID
        self.chapter = chapter
    }
}

/// Builds the rolling set of daily-reminder notifications. Pure logic (no side effects, no
/// `UserNotifications`) so it's fully unit-testable.
///
/// Each upcoming day gets its own one-shot notification carrying *that date's* shloka — resolved
/// through the same `DailyShlokaService` Home and the widget use, so all three always agree on which
/// verse. Only the fire **time** is randomized (per the resolved PRD §10.1): `specific` fires at the
/// chosen time, `window`/`range` at a fresh random minute within the range each day.
public struct NotificationPlanner: Sendable {
    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// The minute-of-day a reminder fires for the given preferences. `randomMinute` is injected so
    /// tests are deterministic; it defaults to `Int.random(in:)`.
    public func resolveFireMinutes(
        _ prefs: Preferences,
        randomMinute: (ClosedRange<Int>) -> Int = { Int.random(in: $0) }
    ) -> Int {
        switch prefs.notificationMode {
        case .specific:
            return prefs.windowStart
        case .window, .range:
            let lo = min(prefs.windowStart, prefs.windowEnd)
            let hi = max(prefs.windowStart, prefs.windowEnd)
            return randomMinute(lo...hi)
        }
    }

    /// Plan the next `days` daily reminders (≤ 64, iOS's pending-notification cap), starting from
    /// `startOfToday`. Returns `[]` when notifications are disabled or there's no content.
    public func plan(
        preferences prefs: Preferences,
        shlokas: [Shloka],
        dailyService: DailyShlokaService,
        startOfToday: Date,
        days: Int = 60,
        randomMinute: (ClosedRange<Int>) -> Int = { Int.random(in: $0) }
    ) -> [PlannedNotification] {
        guard prefs.notificationsEnabled, !shlokas.isEmpty, days > 0 else { return [] }

        var planned: [PlannedNotification] = []
        for offset in 0..<min(days, 64) {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfToday),
                  let shloka = dailyService.dailyShloka(for: date, in: shlokas) else { continue }

            let minutes = resolveFireMinutes(prefs, randomMinute: randomMinute)
            var comps = calendar.dateComponents([.year, .month, .day], from: date)
            comps.hour = minutes / 60
            comps.minute = minutes % 60

            let firstPada = shloka.verseLines.first ?? shloka.transliteration
            planned.append(PlannedNotification(
                id: "daily-\(dailyService.dayKey(for: date))",
                fireDate: comps,
                title: "Bhagavad Gita \(shloka.reference)",
                body: "\(firstPada) — \(shloka.meaning)",
                shlokaID: shloka.id,
                chapter: shloka.chapter
            ))
        }
        return planned
    }
}
