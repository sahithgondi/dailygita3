import SwiftUI
import WidgetKit
import GitaKit

/// App-wide dependencies created once at launch and shared via the SwiftUI environment.
///
/// Holds the read-only content store, the user-data store (SwiftData + CloudKit), and the
/// deterministic daily-shloka service. Also publishes the day's shloka to the App Group so the
/// widget can render it (impl plan §5, §6) — this is the Phase 0 proof that the app→widget channel
/// works before any real data exists.
@Observable
final class AppModel {
    let contentStore: ContentStore
    let userStore: UserStore
    let dailyService: DailyShlokaService

    private let planner = NotificationPlanner()
    private let scheduler = NotificationScheduler()

    init(contentStore: ContentStore, userStore: UserStore, dailyService: DailyShlokaService = DailyShlokaService()) {
        self.contentStore = contentStore
        self.userStore = userStore
        self.dailyService = dailyService
    }

    /// All chapters the app offers — the full Gita (1...18), every chapter populated from the
    /// bundled content (gita.json).
    let allChapters = Array(1...18)

    var todayShloka: Shloka? {
        dailyService.dailyShloka(for: .now, in: contentStore.shlokas)
    }

    /// Write today's shloka to the App Group and nudge the widget to reload. Safe to call on every
    /// foreground; the payload is tagged with the day key so the widget can detect staleness.
    func publishDailyShlokaToWidget(now: Date = .now) {
        guard let shloka = todayShloka else { return }
        let payload = DailyShlokaPayload(
            dayKey: dailyService.dayKey(for: now),
            reference: shloka.reference,
            speaker: shloka.speaker,
            transliteration: shloka.transliteration,
            meaning: shloka.meaning
        )
        AppGroupStore.shared.writeDailyShloka(payload)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: Daily notifications (Phase 4)

    /// Ask for notification permission. Call when the user turns reminders on.
    func requestNotificationAuthorization() async -> Bool {
        await scheduler.requestAuthorization()
    }

    /// Rebuild the rolling window of daily reminders from current preferences. Safe to call on every
    /// foreground and whenever preferences change; an empty plan (reminders off) clears them. The
    /// notification for each day carries that day's shloka — the same one Home and the widget show.
    func scheduleDailyNotifications(now: Date = .now) {
        let prefs = AppGroupStore.shared.readPreferences()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let plan = planner.plan(
            preferences: prefs,
            shlokas: contentStore.shlokas,
            dailyService: dailyService,
            startOfToday: startOfToday
        )
        scheduler.apply(plan)
    }
}
