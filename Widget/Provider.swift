import WidgetKit
import GitaKit

/// One timeline entry = the day's shloka payload (or nil if the app hasn't written one yet).
struct DailyShlokaEntry: TimelineEntry {
    let date: Date
    let payload: DailyShlokaPayload?
}

/// Feeds the widget. Reads the day's shloka from the App Group (written by the app — impl plan §5)
/// and schedules the timeline to reload at the next local midnight so the verse rolls over with the
/// day (impl plan §6, gita-pages.md W1/W2). No network, no app launch required.
struct Provider: TimelineProvider {
    private let store = AppGroupStore.shared
    private let daily = DailyShlokaService()

    func placeholder(in context: Context) -> DailyShlokaEntry {
        DailyShlokaEntry(date: .now, payload: Self.placeholderPayload)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyShlokaEntry) -> Void) {
        completion(DailyShlokaEntry(date: .now, payload: store.readDailyShloka() ?? Self.placeholderPayload))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyShlokaEntry>) -> Void) {
        let now = Date.now
        let entry = DailyShlokaEntry(date: now, payload: store.readDailyShloka())
        let timeline = Timeline(entries: [entry], policy: .after(daily.nextMidnight(after: now)))
        completion(timeline)
    }

    /// Shown in the widget gallery / before the app has written anything.
    static let placeholderPayload = DailyShlokaPayload(
        dayKey: "",
        reference: "2.47",
        transliteration: "karmaṇy-evādhikāras te",
        meaning: "(Placeholder) You have a right to action alone, never to its fruits."
    )
}
