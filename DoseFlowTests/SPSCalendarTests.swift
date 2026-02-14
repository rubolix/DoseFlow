import XCTest
@testable import DoseFlow

final class SPSCalendarTests: XCTestCase {
    let sps = SPSCalendar()
    let cal = Calendar.current

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        return cal.date(from: c)!
    }

    // MARK: - School Days

    func testRegularSchoolDay() {
        // Wednesday Sep 3, 2025 - first day of school
        XCTAssertTrue(sps.isSchoolDay(date(2025, 9, 3)), "First day of school should be a school day")
    }

    func testWeekendNotSchoolDay() {
        // Saturday Sep 6, 2025
        XCTAssertFalse(sps.isSchoolDay(date(2025, 9, 6)), "Saturday should not be a school day")
        // Sunday Sep 7, 2025
        XCTAssertFalse(sps.isSchoolDay(date(2025, 9, 7)), "Sunday should not be a school day")
    }

    func testBeforeSchoolNotSchoolDay() {
        // Sep 1, 2025 - before school starts
        XCTAssertFalse(sps.isSchoolDay(date(2025, 9, 1)), "Before school year should not be a school day")
    }

    func testAfterSchoolNotSchoolDay() {
        // Jun 18, 2026 - after last day
        XCTAssertFalse(sps.isSchoolDay(date(2026, 6, 18)), "After school year should not be a school day")
    }

    func testLastDayOfSchool() {
        // Jun 17, 2026 - last day
        XCTAssertTrue(sps.isSchoolDay(date(2026, 6, 17)), "Last day should be a school day")
    }

    // MARK: - Holidays

    func testVeteransDay() {
        XCTAssertFalse(sps.isSchoolDay(date(2025, 11, 11)), "Veterans Day should not be a school day")
    }

    func testThanksgiving() {
        XCTAssertFalse(sps.isSchoolDay(date(2025, 11, 27)), "Thanksgiving Thursday should not be a school day")
        XCTAssertFalse(sps.isSchoolDay(date(2025, 11, 28)), "Thanksgiving Friday should not be a school day")
    }

    func testWinterBreak() {
        XCTAssertFalse(sps.isSchoolDay(date(2025, 12, 22)), "First day of winter break")
        XCTAssertFalse(sps.isSchoolDay(date(2025, 12, 25)), "Christmas Day")
        XCTAssertFalse(sps.isSchoolDay(date(2026, 1, 1)), "New Year's Day")
        XCTAssertFalse(sps.isSchoolDay(date(2026, 1, 2)), "Last day of winter break")
    }

    func testDayAfterWinterBreak() {
        // Jan 5, 2026 is a Monday - should be back in school
        XCTAssertTrue(sps.isSchoolDay(date(2026, 1, 5)), "Monday after winter break should be school day")
    }

    func testMLKDay() {
        XCTAssertFalse(sps.isSchoolDay(date(2026, 1, 19)), "MLK Day should not be a school day")
    }

    func testMidWinterBreak() {
        XCTAssertFalse(sps.isSchoolDay(date(2026, 2, 16)), "Mid-winter break Monday")
        XCTAssertFalse(sps.isSchoolDay(date(2026, 2, 20)), "Mid-winter break Friday")
    }

    func testSpringBreak() {
        XCTAssertFalse(sps.isSchoolDay(date(2026, 4, 13)), "Spring break Monday")
        XCTAssertFalse(sps.isSchoolDay(date(2026, 4, 17)), "Spring break Friday")
    }

    func testMemorialDay() {
        XCTAssertFalse(sps.isSchoolDay(date(2026, 5, 25)), "Memorial Day should not be a school day")
    }

    func testStateInServiceDay() {
        XCTAssertFalse(sps.isSchoolDay(date(2025, 10, 10)), "State In-Service Day should not be a school day")
    }

    func testConferenceDays() {
        XCTAssertFalse(sps.isSchoolDay(date(2025, 11, 24)), "Conference day 1")
        XCTAssertFalse(sps.isSchoolDay(date(2025, 11, 25)), "Conference day 2")
        XCTAssertFalse(sps.isSchoolDay(date(2025, 11, 26)), "Conference day 3")
    }

    // MARK: - Regular week during school year

    func testFullWeekInOctober() {
        // Oct 6-10, 2025 (Mon-Fri), but Oct 10 is in-service
        XCTAssertTrue(sps.isSchoolDay(date(2025, 10, 6)), "Monday")
        XCTAssertTrue(sps.isSchoolDay(date(2025, 10, 7)), "Tuesday")
        XCTAssertTrue(sps.isSchoolDay(date(2025, 10, 8)), "Wednesday")
        XCTAssertTrue(sps.isSchoolDay(date(2025, 10, 9)), "Thursday")
        XCTAssertFalse(sps.isSchoolDay(date(2025, 10, 10)), "Friday - In-Service")
    }
}
