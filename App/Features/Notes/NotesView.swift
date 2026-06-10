import SwiftUI
import SwiftData
import GitaKit

/// P9 — Notes (gita-pages.md §9b). Every shloka the reader has annotated, most-recently-edited first;
/// tap deep-links into the shloka's chapter. Mirrors `BookmarksView`. Calm empty state when none.
struct NotesView: View {
    @Environment(AppModel.self) private var model
    @Binding var path: [Route]

    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]

    var body: some View {
        Group {
            if notes.isEmpty {
                ContentUnavailableView(
                    "No notes yet",
                    systemImage: "note.text",
                    description: Text("Add a note to a shloka while reading and it’ll show up here.")
                )
            } else {
                List {
                    ForEach(notes) { note in
                        if let id = note.shlokaID, let shloka = model.contentStore.shloka(id: id) {
                            Button {
                                path.append(.chapterForShloka(shlokaID: id, chapter: shloka.chapter))
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(shloka.reference).font(.caption).foregroundStyle(.secondary)
                                    Text(shloka.verseLines.first ?? shloka.transliteration)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    if let text = note.text, !text.isEmpty {
                                        Text(text)
                                            .font(.body)
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notes")
    }
}
