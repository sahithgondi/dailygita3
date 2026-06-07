import Foundation
import SwiftData

/// A bookmark on a shloka. User data: SwiftData + CloudKit private DB (gita-security.md §1, §3).
///
/// CloudKit-synced model rules we must follow (gita-security.md §3 / CLAUDE.md §5):
/// - every attribute is optional or has a default value,
/// - no `@Attribute(.unique)` — uniqueness (one bookmark per shloka) is enforced in `UserStore`.
@Model
public final class Bookmark {
    /// The bookmarked shloka's `Shloka.id`, e.g. "2.47".
    public var shlokaID: String?
    public var createdAt: Date?

    public init(shlokaID: String? = nil, createdAt: Date? = nil) {
        self.shlokaID = shlokaID
        self.createdAt = createdAt
    }
}
