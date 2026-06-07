import Foundation

/// Read-only access to the bundled shloka content (gita-security.md §1 — content is never synced).
///
/// Phase 0 returns a few **hardcoded** sample shlokas so the shell renders and is testable; Phase 1
/// replaces `sampleShlokas` with the real 700 loaded from `gita.json` via `ContentLoader`.
public struct ContentStore: Sendable {
    public let shlokas: [Shloka]

    public init(shlokas: [Shloka] = ContentStore.sampleShlokas) {
        self.shlokas = shlokas
    }

    /// All shlokas in a chapter, ordered by number.
    public func shlokas(inChapter chapter: Int) -> [Shloka] {
        shlokas.filter { $0.chapter == chapter }.sorted { $0.number < $1.number }
    }

    /// Look up a shloka by its `Shloka.id` ("<chapter>.<number>").
    public func shloka(id: String) -> Shloka? {
        shlokas.first { $0.id == id }
    }

    /// Distinct chapter numbers present in the content, ascending.
    public var chapters: [Int] {
        Array(Set(shlokas.map(\.chapter))).sorted()
    }

    /// Placeholder content for the Phase 0 shell. NOT the real text — just enough to wire the UI,
    /// the daily-shloka selection, and the App Group payload before the real pipeline exists.
    public static let sampleShlokas: [Shloka] = [
        Shloka(chapter: 1, number: 1,
               transliteration: "dharma-kṣetre kuru-kṣetre samavetā yuyutsavaḥ",
               meaning: "(Placeholder) On the field of dharma, assembled and eager to fight…"),
        Shloka(chapter: 2, number: 47,
               transliteration: "karmaṇy-evādhikāras te mā phaleṣu kadācana",
               meaning: "(Placeholder) You have a right to action alone, never to its fruits."),
        Shloka(chapter: 2, number: 48,
               transliteration: "yoga-sthaḥ kuru karmāṇi saṅgaṁ tyaktvā dhanañjaya",
               meaning: "(Placeholder) Established in yoga, perform action, abandoning attachment."),
        Shloka(chapter: 9, number: 22,
               transliteration: "ananyāś cintayanto māṁ ye janāḥ paryupāsate",
               meaning: "(Placeholder) To those who worship Me with undivided focus, I carry what they lack."),
        Shloka(chapter: 18, number: 66,
               transliteration: "sarva-dharmān parityajya mām ekaṁ śaraṇaṁ vraja",
               meaning: "(Placeholder) Abandoning all duties, take refuge in Me alone."),
    ]
}
