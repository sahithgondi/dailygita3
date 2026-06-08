import XCTest
@testable import GitaKit

/// Guards the chapter-title table so a dropped row, a gap in numbering, or an empty name fails here
/// rather than rendering a blank heading.
final class ChapterInfoTests: XCTestCase {
    private let all = GitaChapters.all

    func testCoversAllEighteenChaptersInOrder() {
        XCTAssertEqual(all.map(\.number), Array(1...18))
    }

    func testLookupReturnsMatchingChapter() {
        XCTAssertEqual(GitaChapters.chapter(1)?.name, "Arjuna Viṣāda Yoga")
        XCTAssertEqual(GitaChapters.chapter(18)?.englishName, "Liberation through Renunciation")
    }

    func testLookupOutOfRangeIsNil() {
        XCTAssertNil(GitaChapters.chapter(0))
        XCTAssertNil(GitaChapters.chapter(19))
    }

    func testNoEmptyFields() {
        for c in all {
            XCTAssertFalse(c.name.isEmpty, "empty name for chapter \(c.number)")
            XCTAssertFalse(c.englishName.isEmpty, "empty englishName for chapter \(c.number)")
        }
    }
}
