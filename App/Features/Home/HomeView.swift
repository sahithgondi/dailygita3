import SwiftUI
import GitaKit

/// P1 — Home ("Daily Gita") (gita-pages.md §4). The landing page and hub: the daily shloka card on
/// top, then the table of contents that launches into everything else.
struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Binding var path: [Route]

    var body: some View {
        List {
            Section {
                dailyShlokaCard
            }

            Section("Chapters") {
                ForEach(model.allChapters, id: \.self) { chapter in
                    Button("Chapter \(chapter)") { path.append(.chapter(chapter)) }
                }
            }

            Section {
                Button("Bookmarks") { path.append(.bookmarks) }
                Button("Transliteration Guide") { path.append(.guide) }
                Button("Jump to chapter") { path.append(.chapterJump) }
                Button("Settings") { path.append(.settings) }
            }
        }
        .navigationTitle("Daily Gita")
    }

    @ViewBuilder
    private var dailyShlokaCard: some View {
        if let shloka = model.todayShloka {
            Button {
                path.append(.chapter(shloka.chapter))
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today’s shloka")
                        .font(.caption)
                    Text(shloka.transliteration)
                        .font(.headline)
                    Text(shloka.meaning)
                        .font(.subheadline)
                    Text(shloka.reference)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
        } else {
            Text("No shloka available yet.")
        }
    }
}
