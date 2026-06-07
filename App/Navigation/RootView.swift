import SwiftUI
import GitaKit

/// Top-level view: shows Onboarding on first launch (gita-pages.md P0), otherwise the Home-rooted
/// navigation stack. Onboarding is re-runnable from Settings via the same `hasOnboarded` flag.
struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase
    @State private var path: [Route] = []

    var body: some View {
        Group {
            if hasOnboarded {
                NavigationStack(path: $path) {
                    HomeView(path: $path)
                        .navigationDestination(for: Route.self) { route in
                            destination(for: route)
                        }
                }
            } else {
                OnboardingView(onFinish: { hasOnboarded = true })
            }
        }
        // Keep the widget's daily shloka fresh whenever the app becomes active.
        .task { model.publishDailyShlokaToWidget() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.publishDailyShlokaToWidget() }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .chapter(let chapter):
            ChapterReadingView(chapter: chapter, path: $path)
        case .chapterForShloka(let shlokaID, let chapter):
            ChapterReadingView(chapter: chapter, focusShlokaID: shlokaID, path: $path)
        case .bookmarks:
            BookmarksView(path: $path)
        case .guide:
            TransliterationGuideView()
        case .settings:
            SettingsView()
        case .chapterJump:
            ChapterJumpView(path: $path)
        }
    }
}
