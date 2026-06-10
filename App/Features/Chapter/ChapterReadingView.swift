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
    private var info: ChapterInfo? { GitaChapters.chapter(chapter) }
    private var hasPrevious: Bool { chapter > (model.allChapters.first ?? 1) }
    private var hasNext: Bool { chapter < (model.allChapters.last ?? 18) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Theme.cardSpacing) {
                    if let info { heading(info) }

                    if shlokas.isEmpty {
                        // Safety fallback only: with real content bundled, every chapter (1…18) is
                        // populated. This would show solely if gita.json failed to load.
                        Text("No shlokas bundled for this chapter yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(shlokas) { shloka in
                            ShlokaCard(shloka: shloka)
                                .id(shloka.id)
                        }
                    }
                }
                .padding(.horizontal, Theme.screenMargin)
                .padding(.vertical, Theme.cardSpacing)
            }
            .background(Theme.pageBackground)
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
        // Horizontal swipe: left → next chapter, right → previous (gita-pages.md §5). Simultaneous so
        // the vertical ScrollView keeps working; the guard only acts on horizontal-dominant swipes.
        .simultaneousGesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    guard abs(value.translation.width) > 2 * abs(value.translation.height) else { return }
                    if value.translation.width < 0 { go(to: chapter + 1) }
                    else { go(to: chapter - 1) }
                }
        )
    }

    /// Chapter heading (gita-pages.md §5): number + transliterated name + English gloss.
    @ViewBuilder
    private func heading(_ info: ChapterInfo) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Chapter \(chapter) · \(info.name)")
                .font(.title3.weight(.semibold))
            Text(info.englishName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
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
