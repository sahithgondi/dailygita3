import Foundation

/// A single Gita shloka: read-only **content**, never user data and never CloudKit-synced
/// (gita-security.md §1). Plain value type — not a SwiftData `@Model` — because the 700 shlokas are
/// bundled and identical for everyone.
///
/// Phase 0 uses a few hardcoded samples (see `ContentStore`); Phase 1 loads the real 700 from
/// `gita.json` via `ContentLoader`.
public struct Shloka: Codable, Identifiable, Hashable, Sendable {
    public let chapter: Int
    /// Shloka number within its chapter.
    public let number: Int
    /// English transliteration (shown first — PRD §5.2).
    public let transliteration: String
    /// Plain-English meaning shown underneath the transliteration.
    public let meaning: String
    /// Optional editorial footnote. Used for the rare textual-variant verse (chapter 13's opening
    /// question, numbered 13.0 — see `ContentLoader` / Tools/fetch-content). `nil` for all others.
    public let note: String?

    public init(chapter: Int, number: Int, transliteration: String, meaning: String, note: String? = nil) {
        self.chapter = chapter
        self.number = number
        self.transliteration = transliteration
        self.meaning = meaning
        self.note = note
    }

    /// Stable identity used as the key for bookmarks/notes and the App Group payload: "<chapter>.<number>".
    public var id: String { "\(chapter).\(number)" }

    /// Human-facing reference, e.g. "2.47".
    public var reference: String { "\(chapter).\(number)" }
}
