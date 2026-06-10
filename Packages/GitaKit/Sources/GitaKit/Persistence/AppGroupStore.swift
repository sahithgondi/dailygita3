import Foundation

/// The day's shloka, written by the app and read by the widget. A small Codable payload shared
/// across processes via the App Group so the widget renders without launching the app or hitting
/// the network (PRD §5.7, pages W1/W2). Defined in GitaKit so app and widget use the *same* type.
public struct DailyShlokaPayload: Codable, Equatable, Sendable {
    /// The day this payload is for ("yyyy-MM-dd"); lets the widget detect a stale value.
    public let dayKey: String
    public let reference: String
    /// The "<name> uvāca" speaker label, when the verse opens a speech (else nil).
    public let speaker: String?
    /// Padapātha transliteration — one pāda per line, joined by "\n", daṇḍa marks baked in.
    public let transliteration: String
    public let meaning: String

    public init(dayKey: String, reference: String, speaker: String? = nil,
                transliteration: String, meaning: String) {
        self.dayKey = dayKey
        self.reference = reference
        self.speaker = speaker
        self.transliteration = transliteration
        self.meaning = meaning
    }

    /// The pāda lines, split from `transliteration` (the view indents the odd-indexed ones).
    public var verseLines: [String] { transliteration.split(separator: "\n").map(String.init) }

    /// First pāda — a clean one-line teaser for the small widgets (no daṇḍa marks, which sit on the
    /// 2nd/4th lines).
    public var firstPada: String { verseLines.first ?? transliteration }
}

/// Thin wrapper over `UserDefaults(suiteName:)` for the App Group — the cross-process channel
/// between the app and the widget (impl plan §5).
///
/// The `UserDefaults` is **injected** so unit tests can pass a private suite and round-trip without
/// the App Group entitlement (which isn't present under `swift test`/CI). Production uses
/// `AppGroupStore.shared`, backed by `group.com.dailygita`.
public struct AppGroupStore: Sendable {
    /// Must match the App Group capability on BOTH the app and widget targets (impl plan §5).
    public static let suiteName = "group.com.dailygita"

    private let defaults: UserDefaults

    private enum Key {
        static let dailyShloka = "dailyShloka"
        static let preferences = "preferences"
    }

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    /// Production store backed by the App Group suite. Falls back to `.standard` only if the suite
    /// can't be opened (misconfigured entitlement) so callers never crash — the widget would then
    /// read nothing, which is the documented failure mode to watch for (impl plan §5).
    public static let shared = AppGroupStore(defaults: UserDefaults(suiteName: suiteName) ?? .standard)

    // MARK: Daily shloka (app writes, widget reads)

    public func writeDailyShloka(_ payload: DailyShlokaPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: Key.dailyShloka)
    }

    public func readDailyShloka() -> DailyShlokaPayload? {
        guard let data = defaults.data(forKey: Key.dailyShloka) else { return nil }
        return try? JSONDecoder().decode(DailyShlokaPayload.self, from: data)
    }

    // MARK: Preferences (device-local in v1 — impl plan §11.3)

    public func writePreferences(_ prefs: Preferences) {
        guard let data = try? JSONEncoder().encode(prefs) else { return }
        defaults.set(data, forKey: Key.preferences)
    }

    public func readPreferences() -> Preferences {
        guard let data = defaults.data(forKey: Key.preferences),
              let prefs = try? JSONDecoder().decode(Preferences.self, from: data)
        else { return .default }
        return prefs
    }
}
