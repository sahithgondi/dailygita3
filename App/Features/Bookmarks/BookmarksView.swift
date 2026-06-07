import SwiftUI
import SwiftData
import GitaKit

/// P5 — Bookmarks (gita-pages.md §8). All bookmarked shlokas; tap deep-links into the shloka's
/// chapter. Calm empty state when there are none.
struct BookmarksView: View {
    @Environment(AppModel.self) private var model
    @Binding var path: [Route]

    @Query(sort: \Bookmark.createdAt, order: .reverse) private var bookmarks: [Bookmark]

    var body: some View {
        Group {
            if bookmarks.isEmpty {
                ContentUnavailableView(
                    "No bookmarks yet",
                    systemImage: "bookmark",
                    description: Text("Bookmark a shloka while reading and it’ll show up here.")
                )
            } else {
                List {
                    ForEach(bookmarks) { bookmark in
                        if let id = bookmark.shlokaID, let shloka = model.contentStore.shloka(id: id) {
                            Button {
                                path.append(.chapterForShloka(shlokaID: id, chapter: shloka.chapter))
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(shloka.reference).font(.caption).foregroundStyle(.secondary)
                                    Text(shloka.transliteration).font(.body)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
    }
}
