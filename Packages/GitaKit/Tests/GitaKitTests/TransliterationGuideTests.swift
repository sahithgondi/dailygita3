import XCTest
@testable import GitaKit

/// Guards the transliteration chart data so a typo (an underline substring that isn't in its example,
/// a dropped row) fails here rather than rendering wrong.
final class TransliterationGuideTests: XCTestCase {
    private let entries = TransliterationGuide.entries

    func testEntryCountMatchesChart() {
        // 21 (page 1 left) + 21 (page 1 right) + 7 (page 2 left) + 7 (page 2 right) = 56 rows.
        XCTAssertEqual(entries.count, 56)
    }

    func testEveryUnderlineSubstringOccursInItsExample() {
        for e in entries {
            guard let u = e.underline else { continue }
            XCTAssertTrue(
                e.example.contains(u),
                "underline “\(u)” not found in example “\(e.example)” (\(e.iast))"
            )
        }
    }

    func testNoEmptyFields() {
        for e in entries {
            XCTAssertFalse(e.devanagari.isEmpty, "empty devanagari for \(e.iast)")
            XCTAssertFalse(e.iast.isEmpty, "empty iast for \(e.example)")
            XCTAssertFalse(e.example.isEmpty, "empty example for \(e.iast)")
        }
    }

    func testKnownRows() {
        func entry(iast: String, example: String) -> TransliterationEntry? {
            entries.first { $0.iast == iast && $0.example == example }
        }
        XCTAssertEqual(entry(iast: "ā", example: "Car")?.underline, "a")
        XCTAssertEqual(entry(iast: "śa", example: "Shove")?.underline, "Sh")
        XCTAssertEqual(entry(iast: "kṣa", example: "Worksheet")?.underline, "ksh")
        // Legend-marker rows carry no underline.
        XCTAssertNil(entry(iast: "jña", example: "*")?.underline)
        XCTAssertNil(entry(iast: "aḥ", example: "***")?.underline)
    }

    func testNotesPresent() {
        XCTAssertEqual(TransliterationGuide.notes.count, 4)
        XCTAssertTrue(TransliterationGuide.notes[0].contains("Note 1"))
    }
}
