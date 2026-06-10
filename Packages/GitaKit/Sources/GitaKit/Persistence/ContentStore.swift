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

    /// Safety fallback if `gita.json` is ever missing/unreadable (see `ContentLoader`). A handful of
    /// real verses in the same padapātha + meaning format as the bundle, so the app still renders.
    public static let sampleShlokas: [Shloka] = [
        Shloka(chapter: 1, number: 1,
               speaker: "dhṛtarāṣṭra uvāca",
               transliteration: "dharmakṣetre kurukṣetre\nsamavetā yuyutsavaḥ |\nmāmakāḥ pāṇḍavāścaiva\nkimakurvata sañjaya ||1||",
               meaning: "Dhritarashtra said, \"What did my people and the sons of Pandu do when they had assembled together, eager for battle, on the holy plain of Kurukshetra, O Sanjaya?\""),
        Shloka(chapter: 2, number: 47,
               transliteration: "karmaṇyevādhikāraste\nmā phaleṣu kadācana |\nmā karmaphalaheturbhūḥ\nmā te saṅgo'stvakarmaṇi ||47||",
               meaning: "Your right is only to work, but not to its results; do not let the results of action be your motive, nor let your attachment be to inaction."),
        Shloka(chapter: 2, number: 48,
               transliteration: "yogasthaḥ kuru karmāṇi\nsaṅgaṁ tyaktvā dhanañjaya |\nsiddhyasiddhyoḥ samo bhūtvā\nsamatvaṁ yoga ucyate ||48||",
               meaning: "Perform action, O Arjuna, being steadfast in yoga, abandoning attachment and balanced in success and failure; evenness of mind is called yoga."),
        Shloka(chapter: 9, number: 22,
               transliteration: "ananyāścintayanto māṁ\nye janāḥ paryupāsate |\nteṣāṁ nityābhiyuktānāṁ\nyogakṣemaṁ vahāmyaham ||22||",
               meaning: "To those men who worship Me alone, thinking of no other, who are ever devoted, I secure what they lack and preserve what they already possess."),
        Shloka(chapter: 18, number: 66,
               transliteration: "sarvadharmānparityajya\nmāmekaṁ śaraṇaṁ vraja |\nahaṁ tvā sarvapāpebhyaḥ\nmokṣayiṣyāmi mā śucaḥ ||66||",
               meaning: "Abandoning all duties, take refuge in Me alone; I will liberate you from all sins; do not grieve."),
    ]
}
