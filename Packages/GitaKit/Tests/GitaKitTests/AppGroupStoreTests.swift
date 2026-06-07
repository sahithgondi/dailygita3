import XCTest
@testable import GitaKit

/// The App Group store is the app→widget channel (impl plan §5). We inject a private `UserDefaults`
/// suite so the round-trip can be verified under `swift test`/CI without the App Group entitlement.
final class AppGroupStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: AppGroupStore!

    override func setUp() {
        super.setUp()
        suiteName = "test.dailygita.appgroup"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        store = AppGroupStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testDailyShlokaRoundTrip() {
        let payload = DailyShlokaPayload(
            dayKey: "2026-06-07",
            reference: "2.47",
            transliteration: "karmaṇy-evādhikāras te",
            meaning: "Placeholder meaning"
        )
        store.writeDailyShloka(payload)
        XCTAssertEqual(store.readDailyShloka(), payload)
    }

    func testReadDailyShlokaNilWhenEmpty() {
        XCTAssertNil(store.readDailyShloka())
    }

    func testPreferencesDefaultWhenEmpty() {
        XCTAssertEqual(store.readPreferences(), .default)
    }

    func testPreferencesRoundTrip() {
        var prefs = Preferences.default
        prefs.appearance = .dark
        prefs.fontScale = 1.25
        prefs.notificationMode = .specific
        store.writePreferences(prefs)
        XCTAssertEqual(store.readPreferences(), prefs)
    }
}
