import Foundation

/// Title metadata for one of the Gita's 18 chapters: its transliterated Sanskrit name and a short
/// English gloss. Used for the Chapter Reading View heading (gita-pages.md §5, "number + name") and
/// the Home table of contents (§4).
public struct ChapterInfo: Identifiable, Hashable, Sendable {
    /// Chapter number, 1…18.
    public let number: Int
    /// Transliterated Sanskrit name in the same IAST style as the rest of the app, e.g.
    /// "Arjuna Viṣāda Yoga".
    public let name: String
    /// Short plain-English gloss, e.g. "Arjuna's Despair".
    public let englishName: String

    public init(_ number: Int, _ name: String, _ englishName: String) {
        self.number = number
        self.name = name
        self.englishName = englishName
    }

    public var id: Int { number }
}

/// The 18 chapter titles, fixed public-domain reference data. Lives here as a static Swift table —
/// not in `gita.json` — because the names are per-chapter (not per-shloka) and never change, matching
/// the same "hardcoded reference content" pattern as `TransliterationGuide`.
public enum GitaChapters {
    public static let all: [ChapterInfo] = [
        .init(1,  "Arjuna Viṣāda Yoga",            "Arjuna's Despair"),
        .init(2,  "Sāṅkhya Yoga",                  "Self-Knowledge"),
        .init(3,  "Karma Yoga",                    "Selfless Action"),
        .init(4,  "Jñāna Karma Sannyāsa Yoga",     "Wisdom in Action"),
        .init(5,  "Karma Sannyāsa Yoga",           "Renunciation of Action"),
        .init(6,  "Dhyāna Yoga",                   "Meditation"),
        .init(7,  "Jñāna Vijñāna Yoga",            "Knowledge and Realization"),
        .init(8,  "Akṣara Brahma Yoga",            "The Imperishable Absolute"),
        .init(9,  "Rāja Vidyā Rāja Guhya Yoga",    "The Royal Secret"),
        .init(10, "Vibhūti Yoga",                  "Divine Glories"),
        .init(11, "Viśvarūpa Darśana Yoga",        "The Cosmic Vision"),
        .init(12, "Bhakti Yoga",                   "Devotion"),
        .init(13, "Kṣetra Kṣetrajña Vibhāga Yoga", "The Field and Its Knower"),
        .init(14, "Guṇatraya Vibhāga Yoga",        "The Three Gunas"),
        .init(15, "Puruṣottama Yoga",              "The Supreme Person"),
        .init(16, "Daivāsura Sampad Vibhāga Yoga", "The Divine and the Demonic"),
        .init(17, "Śraddhātraya Vibhāga Yoga",     "The Threefold Faith"),
        .init(18, "Mokṣa Sannyāsa Yoga",           "Liberation through Renunciation"),
    ]

    /// Look up a chapter's title by number; `nil` if out of the 1…18 range.
    public static func chapter(_ number: Int) -> ChapterInfo? {
        all.first { $0.number == number }
    }
}
