import SwiftUI

/// P6 — Transliteration Guide (gita-pages.md §9). Static reference for reading the English
/// transliteration. Content is fixed; no interactivity in v1. Phase 0 uses placeholder rows — the
/// real pronunciation reference is filled in later.
struct TransliterationGuideView: View {
    private struct Entry: Identifiable {
        let id = UUID()
        let symbol: String
        let hint: String
    }

    private let entries: [Entry] = [
        Entry(symbol: "ā / ī / ū", hint: "(Placeholder) long vowels — held about twice as long."),
        Entry(symbol: "ṛ", hint: "(Placeholder) a rolled ‘ri’ sound."),
        Entry(symbol: "ś / ṣ", hint: "(Placeholder) ‘sh’ sounds."),
        Entry(symbol: "ṁ / ṅ / ñ / ṇ", hint: "(Placeholder) nasal sounds."),
        Entry(symbol: "kh / gh / ch / th / dh / ph", hint: "(Placeholder) aspirated consonants."),
    ]

    var body: some View {
        List(entries) { entry in
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.symbol).font(.headline)
                Text(entry.hint).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Transliteration Guide")
    }
}
