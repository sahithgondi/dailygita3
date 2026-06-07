import Foundation
import SwiftData

/// A free-text personal note attached to one shloka. The only **personal** data in the app
/// (gita-security.md §9): user data, SwiftData + CloudKit private DB.
///
/// Same CloudKit constraints as `Bookmark`: all attributes optional/defaulted, no unique constraint.
@Model
public final class Note {
    /// The annotated shloka's `Shloka.id`, e.g. "2.47".
    public var shlokaID: String?
    public var text: String?
    public var createdAt: Date?
    public var updatedAt: Date?

    public init(shlokaID: String? = nil, text: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.shlokaID = shlokaID
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
