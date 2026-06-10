import XCTest
@testable import GitaKit

/// Guards the daily-reminder planning: fire-time resolution per mode (with an injected RNG for
/// determinism) and the rolling per-day plan — including that each day's notification carries the
/// same shloka `DailyShlokaService` gives Home and the widget.
final class NotificationPlannerTests: XCTestCase {
    private let planner = NotificationPlanner()
    private let dailyService = DailyShlokaService()
    private let shlokas = ContentLoader().load()
    /// A fixed reference day so date-derived selection is deterministic.
    private let start = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))

    // MARK: resolveFireMinutes

    func testSpecificFiresAtWindowStart() {
        let p = Preferences(notificationMode: .specific, windowStart: 9 * 60, windowEnd: 21 * 60)
        XCTAssertEqual(planner.resolveFireMinutes(p) { _ in 0 }, 9 * 60)
    }

    func testWindowUsesRandomWithinRange() {
        let p = Preferences(notificationMode: .window, windowStart: 8 * 60, windowEnd: 20 * 60)
        // Injected RNG is honored…
        XCTAssertEqual(planner.resolveFireMinutes(p) { $0.lowerBound + 30 }, 8 * 60 + 30)
        // …and the real RNG stays within bounds.
        for _ in 0..<100 {
            XCTAssertTrue((8 * 60...20 * 60).contains(planner.resolveFireMinutes(p)))
        }
    }

    func testRangeToleratesReversedBounds() {
        let p = Preferences(notificationMode: .range, windowStart: 20 * 60, windowEnd: 8 * 60)
        XCTAssertEqual(planner.resolveFireMinutes(p) { $0.lowerBound }, 8 * 60)  // min, not a crash
    }

    // MARK: plan

    func testPlanProducesRequestedDistinctDays() {
        let plan = planner.plan(preferences: Preferences(), shlokas: shlokas,
                                dailyService: dailyService, startOfToday: start, days: 30) { $0.lowerBound }
        XCTAssertEqual(plan.count, 30)
        XCTAssertEqual(Set(plan.map(\.id)).count, 30, "each day needs a unique id")
        XCTAssertTrue(plan.allSatisfy { !$0.title.isEmpty && !$0.body.isEmpty })
    }

    func testPlanIsEmptyWhenDisabled() {
        let p = Preferences(notificationsEnabled: false)
        XCTAssertTrue(planner.plan(preferences: p, shlokas: shlokas,
                                   dailyService: dailyService, startOfToday: start).isEmpty)
    }

    func testPlanCapsAtSixtyFour() {
        let plan = planner.plan(preferences: Preferences(), shlokas: shlokas,
                                dailyService: dailyService, startOfToday: start, days: 365) { $0.lowerBound }
        XCTAssertEqual(plan.count, 64)
    }

    func testTodayPlanAgreesWithDailyService() {
        let plan = planner.plan(preferences: Preferences(), shlokas: shlokas,
                                dailyService: dailyService, startOfToday: start, days: 1) { _ in 600 }
        let expected = dailyService.dailyShloka(for: start, in: shlokas)
        XCTAssertEqual(plan.first?.shlokaID, expected?.id)
        XCTAssertEqual(plan.first?.title, "Bhagavad Gita \(expected!.reference)")
    }

    func testFireDateUsesResolvedTime() {
        let p = Preferences(notificationMode: .specific, windowStart: 14 * 60 + 30)  // 2:30pm
        let plan = planner.plan(preferences: p, shlokas: shlokas,
                                dailyService: dailyService, startOfToday: start, days: 1)
        XCTAssertEqual(plan.first?.fireDate.hour, 14)
        XCTAssertEqual(plan.first?.fireDate.minute, 30)
    }
}
