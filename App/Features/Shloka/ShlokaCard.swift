import SwiftUI
import SwiftData
import GitaKit

/// P2/P3 — one shloka as a card (gita-pages.md §5–6, gita-ui.md). Renders the verse in padapātha
/// form (speaker label, one pāda per line with the 2nd/4th indented, daṇḍa marks), the English
/// meaning beneath a divider, and the reference. A bookmark shows as a star in the corner; a note
/// shows a small marker. Press-and-hold opens the actions (bookmark / note / share).
struct ShlokaCard: View {
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
        [shloka.speaker, shloka.transliteration, "", shloka.meaning, "", "Bhagavad Gita \(shloka.reference)"]
            .compactMap { $0 }
            .joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padaSpacing) {
            if let speaker = shloka.speaker {
                Text(speaker)
                    .font(Theme.speakerFont)
                    .padding(.bottom, 2)
            }

            // Padapātha: one pāda per line; indent the 2nd and 4th (odd indices).
            ForEach(Array(shloka.verseLines.enumerated()), id: \.offset) { index, line in
                Text(line)
                    .font(Theme.verseFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, index.isMultiple(of: 2) ? 0 : Theme.padaIndent)
            }

            Divider().padding(.vertical, 8)

            Text(shloka.meaning)
                .font(Theme.meaningFont)
                .foregroundStyle(.primary)

            if let note = shloka.note {
                Text(note)
                    .font(.caption2)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            Text(shloka.reference)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.cardPadding)
        .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(alignment: .topTrailing) { indicators }
        .contextMenu { actions }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(shlokaID: shloka.id)
        }
    }

    /// Bookmark star + note marker, shown only when set, in the card's top-trailing corner.
    @ViewBuilder
    private var indicators: some View {
        HStack(spacing: 6) {
            if hasNote {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Has note")
            }
            if isBookmarked {
                Image(systemName: "star.fill")
                    .foregroundStyle(Theme.bookmarkStar)
                    .accessibilityLabel("Bookmarked")
            }
        }
        .font(.caption)
        .padding(Theme.cardPadding)
    }

    /// Long-press actions. Same operations that used to be an inline button row, now behind the menu.
    @ViewBuilder
    private var actions: some View {
        Button {
            try? model.userStore.toggleBookmark(shlokaID: shloka.id)
        } label: {
            Label(isBookmarked ? "Remove Bookmark" : "Bookmark",
                  systemImage: isBookmarked ? "star.slash" : "star")
        }
        Button {
            showingNoteEditor = true
        } label: {
            Label(hasNote ? "Edit Note" : "Add Note", systemImage: "square.and.pencil")
        }
        ShareLink(item: shareText) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
}
