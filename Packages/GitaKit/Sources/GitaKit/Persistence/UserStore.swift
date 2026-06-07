import Foundation
import SwiftData

/// Owns the **user-data** SwiftData stack — bookmarks and notes — backed by the CloudKit private
/// database (gita-security.md §1, §3). This is kept entirely separate from bundled shloka content,
/// which is never synced (CLAUDE.md §5).
///
/// Two init paths:
/// - `init(inMemory:)` → production. `cloudKitDatabase: .private(...)` enables iCloud sync.
/// - `init(inMemory: true)` → tests/CI. In-memory + `cloudKitDatabase: .none`, so unit tests run
///   without an iCloud account, entitlements, or signing.
///
/// Uniqueness (one bookmark per shloka) is enforced **in code** here, because `@Attribute(.unique)`
/// is unsupported on CloudKit-synced models (gita-security.md §3).
@MainActor
public final class UserStore {
    public let container: ModelContainer

    /// CloudKit container id; must match the iCloud capability on the app target's entitlements
    /// (dailygita3/dailygita3/dailygita3.entitlements).
    public static let cloudKitContainerID = "iCloud.com.sahithgondi.dailygita"

    /// `nonisolated` so the stack can be constructed from any context (e.g. the app's `init`),
    /// while the CRUD methods below stay main-actor isolated because they touch `mainContext`.
    public nonisolated init(inMemory: Bool = false) throws {
        let schema = Schema([Bookmark.self, Note.self])
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        } else {
            configuration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private(Self.cloudKitContainerID)
            )
        }
        self.container = try ModelContainer(for: schema, configurations: [configuration])
    }

    private var context: ModelContext { container.mainContext }

    // MARK: Bookmarks

    public func isBookmarked(shlokaID: String) -> Bool {
        guard let result = try? fetchBookmark(shlokaID: shlokaID) else { return false }
        return result != nil
    }

    private func fetchBookmark(shlokaID: String) throws -> Bookmark? {
        let descriptor = FetchDescriptor<Bookmark>(predicate: #Predicate { $0.shlokaID == shlokaID })
        return try context.fetch(descriptor).first
    }

    /// Toggles a bookmark and returns the new state. Enforces one-per-shloka in code.
    @discardableResult
    public func toggleBookmark(shlokaID: String, now: Date = .now) throws -> Bool {
        if let existing = try fetchBookmark(shlokaID: shlokaID) {
            context.delete(existing)
            try context.save()
            return false
        } else {
            context.insert(Bookmark(shlokaID: shlokaID, createdAt: now))
            try context.save()
            return true
        }
    }

    public func allBookmarks() throws -> [Bookmark] {
        let descriptor = FetchDescriptor<Bookmark>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    // MARK: Notes

    public func note(shlokaID: String) throws -> Note? {
        let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.shlokaID == shlokaID })
        return try context.fetch(descriptor).first
    }

    /// Creates or updates the note for a shloka (one note per shloka, enforced in code).
    @discardableResult
    public func upsertNote(shlokaID: String, text: String, now: Date = .now) throws -> Note {
        if let existing = try note(shlokaID: shlokaID) {
            existing.text = text
            existing.updatedAt = now
            try context.save()
            return existing
        } else {
            let note = Note(shlokaID: shlokaID, text: text, createdAt: now, updatedAt: now)
            context.insert(note)
            try context.save()
            return note
        }
    }

    public func deleteNote(shlokaID: String) throws {
        if let existing = try note(shlokaID: shlokaID) {
            context.delete(existing)
            try context.save()
        }
    }

    public func allNotes() throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
