import Foundation

/// User preferences: notification timing, font size, appearance (PRD §7, gita-pages.md P7).
///
/// v1 keeps preferences **device-local in the App Group store** rather than CloudKit-synced
/// (impl plan §11.3 — the recommended v1 path; sync can be added later). So this is a plain
/// `Codable` value type stored via `AppGroupStore`, not a SwiftData `@Model`.
///
/// Phase 0 only needs the shape to exist and round-trip; notification scheduling is Phase 4.
public struct Preferences: Codable, Equatable, Sendable {
    public enum Appearance: String, Codable, CaseIterable, Sendable {
        case system, light, dark
    }

    /// How the daily reminder time is chosen. "Custom range" semantics remain an open product
    /// decision (PRD §10.2) — not resolved in Phase 0; we just model the shape.
    public enum NotificationMode: String, Codable, CaseIterable, Sendable {
        case window   // default: a time within an 8am–8pm window
        case specific // a specific time of day
        case range    // a custom range a time is chosen within
    }

    public var notificationsEnabled: Bool
    public var notificationMode: NotificationMode
    /// Minutes-from-midnight bounds used by `window`/`range` modes; `specific` uses `windowStart`.
    public var windowStart: Int
    public var windowEnd: Int
    /// Reading text scale multiplier; respects Dynamic Type where possible (gita-pages.md P7).
    public var fontScale: Double
    public var appearance: Appearance

    public init(
        notificationsEnabled: Bool = true,
        notificationMode: NotificationMode = .window,
        windowStart: Int = 8 * 60,   // 8:00am
        windowEnd: Int = 20 * 60,    // 8:00pm
        fontScale: Double = 1.0,
        appearance: Appearance = .system
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.notificationMode = notificationMode
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.fontScale = fontScale
        self.appearance = appearance
    }

    /// The onboarding default a user is never blocked on (gita-pages.md P0): 8am–8pm window.
    public static let `default` = Preferences()
}
