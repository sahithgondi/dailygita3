import SwiftUI
import SwiftData
import GitaKit

/// P3 — Shloka interactions (gita-pages.md §6). One shloka rendered as transliteration then meaning,
/// with inline affordances: bookmark toggle, add/edit note (opens the editor sheet), and share.
struct ShlokaRow: View {
    let shloka: Shloka

    @Environment(AppModel.self) private var model
    @State private var showingNoteEditor = false

    // Reactive bookmark/note state for THIS shloka, read from the same store the writes go to.
    @Query private var bookmarks: [Bookmark]
    @Query private var notes: [Note]

    init(shloka: Shloka) {
        self.shloka = shloka
        let id = shloka.id
        _bookmarks = Query(filter: #Predicate<Bookmark> { $0.shlokaID == id })
        _notes = Query(filter: #Predicate<Note> { $0.shlokaID == id })
    }

    private var isBookmarked: Bool { !bookmarks.isEmpty }
    private var hasNote: Bool { !notes.isEmpty }

    private var shareText: String {
        "\(shloka.transliteration)\n\n\(shloka.meaning)\n\nBhagavad Gita \(shloka.reference)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(shloka.transliteration)
                .font(.headline)
            Text(shloka.meaning)
                .font(.body)
            Text(shloka.reference)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let note = shloka.note {
                Text(note)
                    .font(.caption2)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                Button {
                    try? model.userStore.toggleBookmark(shlokaID: shloka.id)
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Add bookmark")

                Button {
                    showingNoteEditor = true
                } label: {
                    Image(systemName: hasNote ? "note.text" : "square.and.pencil")
                }
                .accessibilityLabel(hasNote ? "Edit note" : "Add note")

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share shloka")
            }
            .buttonStyle(.borderless)
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(shlokaID: shloka.id)
        }
    }
}
