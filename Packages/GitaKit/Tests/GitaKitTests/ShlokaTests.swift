import XCTest
@testable import GitaKit

/// Unit tests for the `Shloka` value type: JSON decoding of the optional `speaker`, identity/reference
/// derivation, and the `verseLines` padapātha helper the reading card relies on.
final class ShlokaTests: XCTestCase {
    private func decode(_ json: String) throws -> Shloka {
        try JSONDecoder().decode(Shloka.self, from: Data(json.utf8))
    }

    func testDecodesWithSpeaker() throws {
        let s = try decode(#"""
        { "chapter": 1, "number": 1, "speaker": "dhṛtarāṣṭra uvāca",
          "transliteration": "dharmakṣetre kurukṣetre\nsamavetā yuyutsavaḥ |\nmāmakāḥ pāṇḍavāścaiva\nkimakurvata sañjaya ||1||",
          "meaning": "Dhritarashtra said…" }
        """#)
        XCTAssertEqual(s.speaker, "dhṛtarāṣṭra uvāca")
        XCTAssertEqual(s.id, "1.1")
        XCTAssertEqual(s.reference, "1.1")
        XCTAssertEqual(s.verseLines.count, 4)
        XCTAssertEqual(s.verseLines[1], "samavetā yuyutsavaḥ |")  // 2nd pāda → indented by the view
    }

    func testDecodesWithoutSpeaker() throws {
        // A missing "speaker" key decodes to nil (the common case — most verses continue a speech).
        let s = try decode(#"""
        { "chapter": 2, "number": 47,
          "transliteration": "karmaṇyevādhikāraste\nmā phaleṣu kadācana |\nmā karmaphalaheturbhūḥ\nmā te saṅgo'stvakarmaṇi ||47||",
          "meaning": "Your right is only to work…" }
        """#)
        XCTAssertNil(s.speaker)
        XCTAssertNil(s.note)
        XCTAssertEqual(s.verseLines.count, 4)
    }

    func testVerseLinesHandlesTwoLineFallback() {
        let s = Shloka(chapter: 9, number: 1,
                       transliteration: "first hemistich |\nsecond hemistich ||1||",
                       meaning: "x")
        XCTAssertEqual(s.verseLines, ["first hemistich |", "second hemistich ||1||"])
    }
}
