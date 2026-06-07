import XCTest
@testable import GitaKit

final class ContentStoreTests: XCTestCase {
    private let store = ContentStore()

    func testShlokaLookupByID() {
        let shloka = store.shloka(id: "2.47")
        XCTAssertEqual(shloka?.chapter, 2)
        XCTAssertEqual(shloka?.number, 47)
    }

    func testShlokaLookupMissingIsNil() {
        XCTAssertNil(store.shloka(id: "99.99"))
    }

    func testShlokasInChapterAreSorted() {
        let chapter2 = store.shlokas(inChapter: 2)
        XCTAssertEqual(chapter2.map(\.number), [47, 48])
    }

    func testChaptersAreDistinctAndSorted() {
        XCTAssertEqual(store.chapters, [1, 2, 9, 18])
    }

    func testReferenceFormat() {
        XCTAssertEqual(store.shloka(id: "18.66")?.reference, "18.66")
    }

    func testContentLoaderReturnsSamplesInPhase0() {
        XCTAssertEqual(ContentLoader().load(), ContentStore.sampleShlokas)
    }
}
