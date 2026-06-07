import SwiftUI
import GitaKit

/// P8 — Chapter Jump (gita-pages.md §11). v1 "search": pick a chapter 1–18 to navigate directly to
/// its reading view. Full-text search is deferred (PRD §4); this is built so it can grow later
/// without restructuring navigation.
struct ChapterJumpView: View {
    @Environment(AppModel.self) private var model
    @Binding var path: [Route]

    var body: some View {
        List(model.allChapters, id: \.self) { chapter in
            Button("Chapter \(chapter)") {
                path.append(.chapter(chapter))
            }
        }
        .navigationTitle("Jump to chapter")
    }
}
