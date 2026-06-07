import XCTest
import SwiftData
@testable import GitaKit

/// Exercises the user-data CRUD against an in-memory store (no CloudKit, no signing) so it runs in
/// CI. Covers the one-bookmark-per-shloka and one-note-per-shloka rules enforced in code, since
/// CloudKit forbids unique constraints (gita-security.md §3).
@MainActor
final class UserStoreTests: XCTestCase {
    private func makeStore() throws -> UserStore { try UserStore(inMemory: true) }

    func testBookmarkToggleCreatesAndRemoves() throws {
        let store = try makeStore()
        XCTAssertFalse(store.isBookmarked(shlokaID: "2.47"))

        let on = try store.toggleBookmark(shlokaID: "2.47")
        XCTAssertTrue(on)
        XCTAssertTrue(store.isBookmarked(shlokaID: "2.47"))
        XCTAssertEqual(try store.allBookmarks().count, 1)

        let off = try store.toggleBookmark(shlokaID: "2.47")
        XCTAssertFalse(off)
        XCTAssertFalse(store.isBookmarked(shlokaID: "2.47"))
        XCTAssertEqual(try store.allBookmarks().count, 0)
    }

    func testOneBookmarkPerShloka() throws {
        let store = try makeStore()
        _ = try store.toggleBookmark(shlokaID: "2.47")
        // Toggling again removes rather than duplicating — never two bookmarks for one shloka.
        _ = try store.toggleBookmark(shlokaID: "2.47")
        _ = try store.toggleBookmark(shlokaID: "2.47")
        XCTAssertEqual(try store.allBookmarks().filter { $0.shlokaID == "2.47" }.count, 1)
    }

    func testNoteUpsertCreatesThenUpdates() throws {
        let store = try makeStore()
        let created = try store.upsertNote(shlokaID: "9.22", text: "first")
        XCTAssertEqual(created.text, "first")
        XCTAssertEqual(try store.allNotes().count, 1)

        let updated = try store.upsertNote(shlokaID: "9.22", text: "second")
        XCTAssertEqual(updated.text, "second")
        XCTAssertEqual(try store.allNotes().count, 1, "upsert must not create a duplicate note")
    }

    func testNoteDelete() throws {
        let store = try makeStore()
        _ = try store.upsertNote(shlokaID: "9.22", text: "to delete")
        try store.deleteNote(shlokaID: "9.22")
        XCTAssertNil(try store.note(shlokaID: "9.22"))
        XCTAssertEqual(try store.allNotes().count, 0)
    }
}
