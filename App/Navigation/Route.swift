import Foundation
import GitaKit

/// Stack-based navigation rooted at Home (gita-pages.md §1 — a NavigationStack, not tabs).
/// Every destination reachable from Home is a case here so the whole app is one typed path.
enum Route: Hashable {
    case chapter(Int)
    case bookmarks
    case guide
    case settings
    case chapterJump

    /// Deep link from Bookmarks into a shloka's chapter (gita-pages.md P5).
    /// Carries the shloka id so the chapter view can scroll to it.
    case chapterForShloka(shlokaID: String, chapter: Int)
}
