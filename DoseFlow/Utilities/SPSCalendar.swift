import Foundation

/// Seattle Public Schools 2025-2026 Calendar
struct SPSCalendar {
    /// First day of school (grades 1-12)
    static let schoolStart = date(2025, 9, 3)
    /// Last day of school
    static let schoolEnd = date(2026, 6, 17)

    /// All no-school dates (holidays, breaks, in-service days)
    let noSchoolDates: Set<Date> = {
        var dates = Set<Date>()

        // Before school starts
        addRange(&dates, from: (2025, 9, 1), to: (2025, 9, 2))

        // State In-Service Day
        dates.insert(date(2025, 10, 10))

        // Veterans Day
        dates.insert(date(2025, 11, 11))

        // Family-Teacher Conferences (elementary/K-8)
        addRange(&dates, from: (2025, 11, 24), to: (2025, 11, 26))

        // Thanksgiving
        addRange(&dates, from: (2025, 11, 27), to: (2025, 11, 28))

        // Winter Break
        addRange(&dates, from: (2025, 12, 22), to: (2026, 1, 2))

        // MLK Day
        dates.insert(date(2026, 1, 19))

        // Mid-Winter Break
        addRange(&dates, from: (2026, 2, 16), to: (2026, 2, 20))

        // Spring Break
        addRange(&dates, from: (2026, 4, 13), to: (2026, 4, 17))

        // Memorial Day
        dates.insert(date(2026, 5, 25))

        return dates
    }()

    /// Check if a given date is a school day
    func isSchoolDay(_ date: Date) -> Bool {
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)

        // Must be within school year
        guard d >= SPSCalendar.schoolStart && d <= SPSCalendar.schoolEnd else {
            return false
        }

        // Not a weekend
        let weekday = cal.component(.weekday, from: d)
        guard weekday != 1 && weekday != 7 else { return false }

        // Not a holiday/break
        return !noSchoolDates.contains(d)
    }

    // MARK: - Helpers

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    private static func addRange(_ set: inout Set<Date>, from start: (Int, Int, Int), to end: (Int, Int, Int)) {
        let cal = Calendar.current
        var current = date(start.0, start.1, start.2)
        let endDate = date(end.0, end.1, end.2)
        while current <= endDate {
            set.insert(current)
            current = cal.date(byAdding: .day, value: 1, to: current)!
        }
    }
}
