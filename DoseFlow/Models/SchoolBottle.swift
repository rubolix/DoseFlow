import Foundation
import SwiftData

@Model
final class SchoolBottle {
    var pillCount: Int
    var dateEntered: Date
    var medication: Medication?

    init(pillCount: Int, dateEntered: Date = .now) {
        self.pillCount = pillCount
        self.dateEntered = dateEntered
    }

    /// School days remaining based on SPS calendar
    func schoolDaysRemaining(calendar: SPSCalendar = SPSCalendar()) -> Int {
        guard pillCount > 0 else { return 0 }
        var count = 0
        var date = dateEntered
        let cal = Calendar.current

        while count < pillCount {
            date = cal.date(byAdding: .day, value: 1, to: date)!
            if calendar.isSchoolDay(date) {
                count += 1
            }
        }
        // count represents pills consumed, so days remaining = pills left
        let daysElapsed = schoolDaysSince(dateEntered, calendar: calendar)
        let remaining = pillCount - daysElapsed
        return max(0, remaining)
    }

    /// School days elapsed since a date
    func schoolDaysSince(_ startDate: Date, calendar: SPSCalendar = SPSCalendar()) -> Int {
        let cal = Calendar.current
        var count = 0
        var date = cal.startOfDay(for: startDate)
        let today = cal.startOfDay(for: Date())

        while date < today {
            date = cal.date(byAdding: .day, value: 1, to: date)!
            if calendar.isSchoolDay(date) {
                count += 1
            }
        }
        return count
    }

    /// Projected date when school bottle runs out
    func projectedRunOutDate(calendar: SPSCalendar = SPSCalendar()) -> Date? {
        let remaining = schoolDaysRemaining(calendar: calendar)
        guard remaining > 0 else { return nil }

        let cal = Calendar.current
        var count = 0
        var date = cal.startOfDay(for: Date())

        while count < remaining {
            date = cal.date(byAdding: .day, value: 1, to: date)!
            if calendar.isSchoolDay(date) {
                count += 1
            }
        }
        return date
    }
}
