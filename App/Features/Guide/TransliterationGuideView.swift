import SwiftUI
import GitaKit

/// P6 — Transliteration Guide (gita-pages.md §9). The pronunciation reference, transcribed from the
/// source chart: each row is a Devanagari glyph, its IAST transliteration, and an English example
/// word with the matching sound underlined. Static content; no interactivity in v1. Data lives in
/// `GitaKit.TransliterationGuide`.
struct TransliterationGuideView: View {
    private let entries = TransliterationGuide.entries
    private let notes = TransliterationGuide.notes

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(TransliterationGuide.title)
                    .font(.title3.weight(.semibold))
                    .padding(.bottom, 4)

                Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 16, verticalSpacing: 12) {
                    ForEach(entries) { entry in
                        GridRow {
                            Text(entry.devanagari)
                                .font(.title3)
                                .gridColumnAlignment(.leading)
                            Text(entry.iast)
                                .font(.callout.weight(.semibold))
                                .gridColumnAlignment(.leading)
                            exampleText(entry)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)
                        }
                    }
                }

                Divider().padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(notes, id: \.self) { note in
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Transliteration Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The example word with its matching-sound substring underlined (first occurrence).
    private func exampleText(_ entry: TransliterationEntry) -> Text {
        var string = AttributedString(entry.example)
        if let underline = entry.underline, let range = string.range(of: underline) {
            string[range].underlineStyle = .single
        }
        return Text(string)
    }
}

#Preview {
    NavigationStack { TransliterationGuideView() }
}
