import Foundation

/// One row of the transliteration & pronunciation chart (gita-pages.md §9): a Devanagari glyph, its
/// IAST transliteration, and an English example word whose matching sound is underlined.
///
/// `underline` is the substring of `example` to underline (first occurrence). It is `nil` for rows
/// with no English example — those use a legend marker in `example` instead (`*`, `**`, `***`,
/// `(Note 1)`, `(Long r)`, `(a)` / `(ā)` …) explained by `TransliterationGuide.notes`.
public struct TransliterationEntry: Identifiable, Hashable, Sendable {
    public let devanagari: String
    public let iast: String
    public let example: String
    public let underline: String?

    public init(_ devanagari: String, _ iast: String, _ example: String, underline: String? = nil) {
        self.devanagari = devanagari
        self.iast = iast
        self.example = example
        self.underline = underline
    }

    public var id: String { devanagari + iast + example }
}

/// The full pronunciation reference, transcribed verbatim from the source chart. Static content —
/// no interactivity in v1. Order follows the chart's two columns across both pages (left column then
/// right column, page 1 then page 2).
public enum TransliterationGuide {
    public static let title = "Transliteration and Pronunciation Guide"

    public static let entries: [TransliterationEntry] = [
        // ── Page 1, left column: oṁ + vowels + ka-varga ──────────────────────────────
        .init("ॐ", "om", "Home", underline: "ome"),
        .init("अ", "a", "Fun", underline: "u"),
        .init("आ", "ā", "Car", underline: "a"),
        .init("इ", "i", "Pin", underline: "i"),
        .init("ई", "ī", "Feet", underline: "ee"),
        .init("उ", "u", "Put", underline: "u"),
        .init("ऊ", "ū", "Pool", underline: "oo"),
        .init("ऋ", "ṛ", "Rig", underline: "Ri"),
        .init("ॠ", "ṝ", "(Long r)"),
        .init("ऌ", "ḷ", "*"),
        .init("ए", "ē", "Play", underline: "ay"),
        .init("ऐ", "ai", "High", underline: "igh"),
        .init("ओ", "ō", "Over", underline: "O"),
        .init("औ", "au", "Cow", underline: "ow"),
        .init("अं", "aṁ / m̐", "**"),
        .init("अः", "aḥ", "***"),
        .init("क", "ka", "Kind", underline: "K"),
        .init("ख", "kha", "Blockhead", underline: "ckh"),
        .init("ग", "ga", "Gate", underline: "G"),
        .init("घ", "gha", "Log-hut", underline: "g-h"),
        .init("ङ", "ṅa", "Sing", underline: "ng"),

        // ── Page 1, right column: ṭa-varga + ta-varga + pa-varga + semivowels + śa ────
        .init("ट", "ṭa", "Touch", underline: "T"),
        .init("ठ", "ṭha", "Ant-hill", underline: "t-h"),
        .init("ड", "ḍa", "Duck", underline: "D"),
        .init("ढ", "ḍha", "Godhood", underline: "dh"),
        .init("ण", "ṇa", "Thunder", underline: "n"),
        .init("त", "ta", "(Close to) Think", underline: "Th"),
        .init("थ", "tha", "(Close to) Pathetic", underline: "th"),
        .init("द", "da", "(Close to) Father", underline: "th"),
        .init("ध", "dha", "(Close to) Breathe hard", underline: "the"),
        .init("न", "na", "Numb", underline: "N"),
        .init("प", "pa", "Purse", underline: "P"),
        .init("फ", "pha", "Sapphire", underline: "pph"),
        .init("ब", "ba", "But", underline: "B"),
        .init("भ", "bha", "Abhor", underline: "bh"),
        .init("म", "ma", "Mother", underline: "M"),
        .init("य", "ya", "Young", underline: "Y"),
        .init("र", "ra", "Run", underline: "R"),
        .init("ल", "la", "Luck", underline: "L"),
        .init("व", "va", "Virtue", underline: "V"),
        .init("श", "śa", "Shove", underline: "Sh"),

        // ── Page 2, left column: ca-varga + tra + avagraha ───────────────────────────
        .init("च", "ca", "Chunk", underline: "Ch"),
        .init("छ", "cha", "Match", underline: "ch"),
        .init("ज", "ja", "Jug", underline: "J"),
        .init("झ", "jha", "Hedgehog", underline: "geh"),
        .init("ञ", "ña", "Bunch", underline: "n"),
        .init("त्र", "tra", "Three", underline: "Thr"),
        .init("ऽ", "'", "Unpronounced A (a)"),

        // ── Page 2, right column: ṣa sa ha + ḷa + kṣa jña + double avagraha ───────────
        .init("ष", "ṣa", "Bushel", underline: "sh"),
        .init("स", "sa", "Sir", underline: "S"),
        .init("ह", "ha", "House", underline: "H"),
        .init("ळ", "(Note 1)", "(Close to) World", underline: "rl"),
        .init("क्ष", "kṣa", "Worksheet", underline: "ksh"),
        .init("ज्ञ", "jña", "*"),
        .init("ऽऽ", "''", "Unpronounced Aa (ā)"),
    ]

    /// Footnotes from the chart, in order: Note 1, then *, **, ***.
    public static let notes: [String] = [
        "Note 1: “ḷ” itself is sometimes used.",
        "*  No English equivalent.",
        "**  Nasalization of the preceding vowel.",
        "***  Aspiration of the preceding vowel.",
    ]
}
