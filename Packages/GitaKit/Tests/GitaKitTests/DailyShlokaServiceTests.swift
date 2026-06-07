import XCTest
@testable import GitaKit

/// Determinism is the whole contract of the daily shloka (PRD §5.1, impl plan §6): same date →
/// same index, identical across app/widget/notification, stable for the day. These tests pin that.
final class DailyShlokaServiceTests: XCTestCase {
    // Fixed UTC calendar so day-of-year is reproducible regardless of where CI runs.
    private func utcCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var cal = utcCalendar()
        return cal.date(from: DateComponents(year: y, month: m, day: d, hour: 12))!
    }

    func testSameDateSameIndex() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        let d = date(2026, 6, 7)
        XCTAssertEqual(svc.shlokaIndex(for: d, total: 700), svc.shlokaIndex(for: d, total: 700))
    }

    func testIndexStableAcrossTimesOfDay() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        let cal = utcCalendar()
        let morning = cal.date(from: DateComponents(year: 2026, month: 6, day: 7, hour: 0, minute: 1))!
        let night = cal.date(from: DateComponents(year: 2026, month: 6, day: 7, hour: 23, minute: 59))!
        XCTAssertEqual(svc.shlokaIndex(for: morning, total: 700), svc.shlokaIndex(for: night, total: 700))
    }

    func testDifferentDaysCanDiffer() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        XCTAssertNotEqual(
            svc.shlokaIndex(for: date(2026, 1, 1), total: 700),
            svc.shlokaIndex(for: date(2026, 1, 2), total: 700)
        )
    }

    func testFirstDayOfYearIsZero() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        XCTAssertEqual(svc.shlokaIndex(for: date(2026, 1, 1), total: 700), 0)
    }

    func testIndexWithinBounds() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        let total = 5
        let cal = utcCalendar()
        let jan1 = cal.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        for day in 1...366 {
            let d = jan1.addingTimeInterval(Double(day - 1) * 86_400)
            let idx = svc.shlokaIndex(for: d, total: total)
            XCTAssertTrue((0..<total).contains(idx))
        }
    }

    func testLeapYearDay366Wraps() {
        // 2024 is a leap year (366 days); day 366 with total 700 = index 365.
        let svc = DailyShlokaService(calendar: utcCalendar())
        XCTAssertEqual(svc.shlokaIndex(for: date(2024, 12, 31), total: 700), 365)
    }

    func testDailyShlokaEmptyListIsNil() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        XCTAssertNil(svc.dailyShloka(for: date(2026, 6, 7), in: []))
    }

    func testDailyShlokaPicksFromList() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        let shloka = svc.dailyShloka(for: date(2026, 1, 1), in: ContentStore.sampleShlokas)
        XCTAssertEqual(shloka, ContentStore.sampleShlokas.first)
    }

    func testDayKeyFormat() {
        let svc = DailyShlokaService(calendar: utcCalendar())
        XCTAssertEqual(svc.dayKey(for: date(2026, 6, 7)), "2026-06-07")
    }
}
