import XCTest
@testable import GitaKit

/// Guards the App-Group payload the widget reads — the padapātha helpers and the optional speaker.
final class DailyShlokaPayloadTests: XCTestCase {
    func testVerseLinesAndFirstPada() {
        let p = DailyShlokaPayload(
            dayKey: "2026-01-01", reference: "1.1", speaker: "dhṛtarāṣṭra uvāca",
            transliteration: "dharmakṣetre kurukṣetre\nsamavetā yuyutsavaḥ |\nmāmakāḥ pāṇḍavāścaiva\nkimakurvata sañjaya ||1||",
            meaning: "x")
        XCTAssertEqual(p.verseLines.count, 4)
        XCTAssertEqual(p.firstPada, "dharmakṣetre kurukṣetre")  // clean teaser, no daṇḍa
    }

    func testDecodesWithoutSpeaker() throws {
        // A payload encoded before `speaker` existed (or for a speaker-less verse) decodes to nil.
        let json = #"{"dayKey":"x","reference":"2.47","transliteration":"karmaṇyevādhikāraste\nmā phaleṣu ||47||","meaning":"m"}"#
        let p = try JSONDecoder().decode(DailyShlokaPayload.self, from: Data(json.utf8))
        XCTAssertNil(p.speaker)
        XCTAssertEqual(p.firstPada, "karmaṇyevādhikāraste")
    }

    func testRoundTripsWithSpeaker() throws {
        let p = DailyShlokaPayload(dayKey: "d", reference: "13.0", speaker: "arjuna uvāca",
                                   transliteration: "a\nb ||0||", meaning: "m")
        let decoded = try JSONDecoder().decode(DailyShlokaPayload.self, from: JSONEncoder().encode(p))
        XCTAssertEqual(decoded, p)
        XCTAssertEqual(decoded.speaker, "arjuna uvāca")
    }
}
