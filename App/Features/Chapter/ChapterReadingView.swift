import SwiftUI
import GitaKit

/// P2 — Chapter Reading View (gita-pages.md §5). The core reading surface: every shloka in the
/// chapter, scrollable, each as transliteration then meaning. Inter-chapter navigation via toolbar
/// arrows, a Home button, and horizontal swipe. Bounds: chapter 1 has no previous, 18 no next.
struct ChapterReadingView: View {
    let chapter: Int
    var focusShlokaID: String? = nil
    @Binding var path: [Route]

    @Environment(AppModel.self) private var model

    private var shlokas: [Shloka] { model.contentStore.shlokas(inChapter: chapter) }
    private var hasPrevious: Bool { chapter > (model.allChapters.first ?? 1) }
    private var hasNext: Bool { chapter < (model.allChapters.last ?? 18) }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if shlokas.isEmpty {
                    // Safety fallback only: with real content bundled, every chapter (1…18) is
                    // populated. This would show solely if gita.json failed to load.
                    Text("No shlokas bundled for this chapter yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(shlokas) { shloka in
                        ShlokaRow(shloka: shloka)
                            .id(shloka.id)
                    }
                }
            }
            .onAppear {
                if let id = focusShlokaID { proxy.scrollTo(id, anchor: .top) }
            }
        }
        .navigationTitle("Chapter \(chapter)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { path.removeAll() } label: { Image(systemName: "house") }
                    .accessibilityLabel("Home")
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { go(to: chapter - 1) } label: { Image(systemName: "chevron.left") }
                    .disabled(!hasPrevious)
                    .accessibilityLabel("Previous chapter")
                Button { go(to: chapter + 1) } label: { Image(systemName: "chevron.right") }
                    .disabled(!hasNext)
                    .accessibilityLabel("Next chapter")
            }
        }
        // Horizontal swipe: left → next chapter, right → previous (gita-pages.md §5).
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 { go(to: chapter + 1) }
                    else { go(to: chapter - 1) }
                }
        )
    }

    /// Replace the top of the stack with the adjacent chapter so the back stack doesn't grow as the
    /// reader pages through chapters; respects bounds.
    private func go(to target: Int) {
        guard model.allChapters.contains(target) else { return }
        if path.isEmpty {
            path = [.chapter(target)]
        } else {
            path[path.count - 1] = .chapter(target)
        }
    }
}
