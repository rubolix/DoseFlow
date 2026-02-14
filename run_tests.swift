#!/usr/bin/env swift

import Foundation

// ============================================================
// INLINE COPIES OF SOURCE CODE FOR TESTING
// (Can't import SwiftData models in a script, so we replicate the logic)
// ============================================================

struct SPSCalendar {
    static let schoolStart = makeDate(2025, 9, 3)
    static let schoolEnd = makeDate(2026, 6, 17)

    let noSchoolDates: Set<Date> = {
        var dates = Set<Date>()
        addRange(&dates, from: (2025, 9, 1), to: (2025, 9, 2))
        dates.insert(makeDate(2025, 10, 10))
        dates.insert(makeDate(2025, 11, 11))
        addRange(&dates, from: (2025, 11, 24), to: (2025, 11, 26))
        addRange(&dates, from: (2025, 11, 27), to: (2025, 11, 28))
        addRange(&dates, from: (2025, 12, 22), to: (2026, 1, 2))
        dates.insert(makeDate(2026, 1, 19))
        addRange(&dates, from: (2026, 2, 16), to: (2026, 2, 20))
        addRange(&dates, from: (2026, 4, 13), to: (2026, 4, 17))
        dates.insert(makeDate(2026, 5, 25))
        return dates
    }()

    func isSchoolDay(_ date: Date) -> Bool {
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)
        guard d >= SPSCalendar.schoolStart && d <= SPSCalendar.schoolEnd else { return false }
        let weekday = cal.component(.weekday, from: d)
        guard weekday != 1 && weekday != 7 else { return false }
        return !noSchoolDates.contains(d)
    }

    static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents(); c.year = year; c.month = month; c.day = day
        return Calendar.current.date(from: c)!
    }
    static func addRange(_ set: inout Set<Date>, from s: (Int,Int,Int), to e: (Int,Int,Int)) {
        let cal = Calendar.current
        var cur = makeDate(s.0, s.1, s.2)
        let end = makeDate(e.0, e.1, e.2)
        while cur <= end { set.insert(cur); cur = cal.date(byAdding: .day, value: 1, to: cur)! }
    }
}

// Medication logic (simplified for testing)
func pillsRemaining(pickupDate: Date, pillCount: Int, pillsPerDay: Int, isArchived: Bool = false, archivedDate: Date? = nil) -> Int {
    let endDate = isArchived ? (archivedDate ?? Date()) : Date()
    let days = Calendar.current.dateComponents([.day], from: pickupDate, to: endDate).day ?? 0
    return max(0, pillCount - (days * pillsPerDay))
}

func runOutDate(pickupDate: Date, pillCount: Int, pillsPerDay: Int, isArchived: Bool = false) -> Date? {
    if isArchived { return nil }
    let totalDays = pillCount / pillsPerDay
    return Calendar.current.date(byAdding: .day, value: totalDays, to: pickupDate)!
}

func orderDate(pickupDate: Date, pillCount: Int, pillsPerDay: Int, isArchived: Bool = false) -> Date? {
    guard let ro = runOutDate(pickupDate: pickupDate, pillCount: pillCount, pillsPerDay: pillsPerDay, isArchived: isArchived) else { return nil }
    return Calendar.current.date(byAdding: .day, value: -7, to: ro)!
}

func earliestPickupDate(pickupDate: Date, pillCount: Int, pillsPerDay: Int, isArchived: Bool = false) -> Date? {
    guard let ro = runOutDate(pickupDate: pickupDate, pillCount: pillCount, pillsPerDay: pillsPerDay, isArchived: isArchived) else { return nil }
    return Calendar.current.date(byAdding: .day, value: -4, to: ro)!
}

func daysRemaining(pickupDate: Date, pillCount: Int, pillsPerDay: Int, isArchived: Bool = false, archivedDate: Date? = nil) -> Int {
    guard let ro = runOutDate(pickupDate: pickupDate, pillCount: pillCount, pillsPerDay: pillsPerDay, isArchived: isArchived) else {
        return isArchived ? pillsRemaining(pickupDate: pickupDate, pillCount: pillCount, pillsPerDay: pillsPerDay, isArchived: isArchived, archivedDate: archivedDate) : 0
    }
    let days = Calendar.current.dateComponents([.day], from: Date(), to: ro).day ?? 0
    return max(0, days)
}

func schoolDaysFromDate(_ startDate: Date, count: Int, calendar: SPSCalendar) -> Date {
    let cal = Calendar.current
    var remaining = count
    var date = cal.startOfDay(for: startDate)
    while remaining > 0 {
        date = cal.date(byAdding: .day, value: 1, to: date)!
        if calendar.isSchoolDay(date) { remaining -= 1 }
        if date > cal.date(byAdding: .year, value: 1, to: startDate)! { break }
    }
    return date
}

// ============================================================
// TEST RUNNER
// ============================================================

var passed = 0
var failed = 0
let d = SPSCalendar.makeDate

func assert(_ condition: Bool, _ msg: String) {
    if condition {
        passed += 1
        print("  ✅ \(msg)")
    } else {
        failed += 1
        print("  ❌ FAIL: \(msg)")
    }
}

let sps = SPSCalendar()
let cal = Calendar.current

// ============================================================
print("\n📋 MEDICATION CALCULATION TESTS")
print("=" * 50)

// Test: pills remaining after 10 days
let tenDaysAgo = cal.date(byAdding: .day, value: -10, to: Date())!
assert(pillsRemaining(pickupDate: tenDaysAgo, pillCount: 30, pillsPerDay: 1) == 20,
       "30 pills, 10 days ago, 1/day → 20 remaining")

// Test: pills can't go below 0
let sixtyDaysAgo = cal.date(byAdding: .day, value: -60, to: Date())!
assert(pillsRemaining(pickupDate: sixtyDaysAgo, pillCount: 30, pillsPerDay: 1) == 0,
       "30 pills, 60 days ago → 0 (not negative)")

// Test: same-day pickup = full count
assert(pillsRemaining(pickupDate: Date(), pillCount: 30, pillsPerDay: 1) == 30,
       "Picked up today → 30 remaining")

// Test: no pickup = 0
assert(pillsRemaining(pickupDate: Date(), pillCount: 0, pillsPerDay: 1) == 0,
       "0 pills → 0 remaining")

// Test: run out date
let today = cal.startOfDay(for: Date())
let expectedRunOut = cal.date(byAdding: .day, value: 30, to: today)!
assert(runOutDate(pickupDate: today, pillCount: 30, pillsPerDay: 1) == expectedRunOut,
       "30 pills from today → runs out in 30 days")

// Test: order date = run out - 7
let expectedOrder = cal.date(byAdding: .day, value: -7, to: expectedRunOut)!
assert(orderDate(pickupDate: today, pillCount: 30, pillsPerDay: 1) == expectedOrder,
       "Order date = run out - 7 days")

// Test: pickup date = run out - 4
let expectedPickup = cal.date(byAdding: .day, value: -4, to: expectedRunOut)!
assert(earliestPickupDate(pickupDate: today, pillCount: 30, pillsPerDay: 1) == expectedPickup,
       "Earliest pickup = run out - 4 days")

// Test: 90-day supply
let expectedRunOut90 = cal.date(byAdding: .day, value: 90, to: today)!
assert(runOutDate(pickupDate: today, pillCount: 90, pillsPerDay: 1) == expectedRunOut90,
       "90 pills → runs out in 90 days")

// ============================================================
print("\n🔒 ARCHIVE FEATURE TESTS")
print("=" * 50)

// Test: archived medication — pills freeze at archive date
let thirtyDaysAgo = cal.date(byAdding: .day, value: -30, to: Date())!
let twentyDaysAgo = cal.date(byAdding: .day, value: -20, to: Date())!
let frozenPills = pillsRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 1, isArchived: true, archivedDate: twentyDaysAgo)
assert(frozenPills == 50,
       "Archived: 60 pills, picked up 30d ago, archived 20d ago → frozen at 50")

// Test: archived medication — pills freeze, not today's count
let activePills = pillsRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 1, isArchived: false)
assert(activePills == 30,
       "Active: 60 pills, picked up 30d ago → 30 remaining (uses today)")
assert(frozenPills != activePills,
       "Archived count differs from active count (frozen vs live)")

// Test: archived medication — run out date returns nil
assert(runOutDate(pickupDate: today, pillCount: 30, pillsPerDay: 1, isArchived: true) == nil,
       "Archived: runOutDate returns nil")

// Test: active medication — run out date returns a value
assert(runOutDate(pickupDate: today, pillCount: 30, pillsPerDay: 1, isArchived: false) != nil,
       "Active: runOutDate returns a date")

// Test: archived medication — order date returns nil
assert(orderDate(pickupDate: today, pillCount: 30, pillsPerDay: 1, isArchived: true) == nil,
       "Archived: orderDate returns nil")

// Test: active medication — order date returns a value
assert(orderDate(pickupDate: today, pillCount: 30, pillsPerDay: 1, isArchived: false) != nil,
       "Active: orderDate returns a date")

// Test: archived medication — earliest pickup date returns nil
assert(earliestPickupDate(pickupDate: today, pillCount: 30, pillsPerDay: 1, isArchived: true) == nil,
       "Archived: earliestPickupDate returns nil")

// Test: active medication — earliest pickup date returns a value
assert(earliestPickupDate(pickupDate: today, pillCount: 30, pillsPerDay: 1, isArchived: false) != nil,
       "Active: earliestPickupDate returns a date")

// Test: archived — pills frozen at 0 if archived after all pills consumed
let longAgo = cal.date(byAdding: .day, value: -100, to: Date())!
let archivedAfterEmpty = cal.date(byAdding: .day, value: -50, to: Date())!
assert(pillsRemaining(pickupDate: longAgo, pillCount: 30, pillsPerDay: 1, isArchived: true, archivedDate: archivedAfterEmpty) == 0,
       "Archived after all consumed → frozen at 0")

// Test: archived same day as pickup — full count preserved
assert(pillsRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 1, isArchived: true, archivedDate: thirtyDaysAgo) == 60,
       "Archived same day as pickup → full 60 pills frozen")

// Test: daysRemaining returns frozen pill count when archived (no run-out date)
let archivedDays = daysRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 1, isArchived: true, archivedDate: twentyDaysAgo)
assert(archivedDays == 50,
       "Archived daysRemaining returns frozen pill count (50)")

// Test: unarchive restores normal behavior — simulated by isArchived=false
let unarchived = pillsRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 1, isArchived: false)
assert(unarchived == 30,
       "Unarchived: resumes normal calculation (30 remaining)")

// Test: archive with 2 pills/day
let twoPillsFrozen = pillsRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 2, isArchived: true, archivedDate: twentyDaysAgo)
assert(twoPillsFrozen == 40,
       "Archived: 60 pills, 2/day, picked up 30d ago, archived 20d ago → frozen at 40")

// Test: active same scenario with 2 pills/day
let twoPillsActive = pillsRemaining(pickupDate: thirtyDaysAgo, pillCount: 60, pillsPerDay: 2, isArchived: false)
assert(twoPillsActive == 0,
       "Active: 60 pills, 2/day, 30 days → 0 remaining")

// ============================================================
print("\n🏫 SPS CALENDAR TESTS")
print("=" * 50)

// School days
assert(sps.isSchoolDay(d(2025, 9, 3)), "Sep 3 (first day) = school day")
assert(sps.isSchoolDay(d(2025, 9, 4)), "Sep 4 (Thursday) = school day")
assert(sps.isSchoolDay(d(2025, 9, 5)), "Sep 5 (Friday) = school day")
assert(sps.isSchoolDay(d(2026, 6, 17)), "Jun 17 (last day) = school day")

// Weekends
assert(!sps.isSchoolDay(d(2025, 9, 6)), "Sep 6 (Saturday) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 9, 7)), "Sep 7 (Sunday) ≠ school day")

// Before/after school year
assert(!sps.isSchoolDay(d(2025, 9, 1)), "Sep 1 (before start) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 9, 2)), "Sep 2 (before start) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 6, 18)), "Jun 18 (after end) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 8, 1)), "Aug 1 (summer) ≠ school day")

// Holidays
assert(!sps.isSchoolDay(d(2025, 10, 10)), "Oct 10 (In-Service) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 11, 11)), "Nov 11 (Veterans Day) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 11, 24)), "Nov 24 (Conference) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 11, 27)), "Nov 27 (Thanksgiving) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 11, 28)), "Nov 28 (Thanksgiving Fri) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 12, 22)), "Dec 22 (Winter Break start) ≠ school day")
assert(!sps.isSchoolDay(d(2025, 12, 25)), "Dec 25 (Christmas) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 1, 1)), "Jan 1 (New Year) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 1, 2)), "Jan 2 (Winter Break end) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 1, 19)), "Jan 19 (MLK Day) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 2, 16)), "Feb 16 (Mid-Winter) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 2, 20)), "Feb 20 (Mid-Winter) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 4, 13)), "Apr 13 (Spring Break) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 4, 17)), "Apr 17 (Spring Break) ≠ school day")
assert(!sps.isSchoolDay(d(2026, 5, 25)), "May 25 (Memorial Day) ≠ school day")

// Day after breaks
assert(sps.isSchoolDay(d(2026, 1, 5)), "Jan 5 (Mon after Winter Break) = school day")
assert(sps.isSchoolDay(d(2026, 2, 23)), "Feb 23 (Mon after Mid-Winter) = school day")
assert(sps.isSchoolDay(d(2026, 4, 20)), "Apr 20 (Mon after Spring Break) = school day")

// Full week check (Oct 6-10, with Oct 10 = in-service)
assert(sps.isSchoolDay(d(2025, 10, 6)), "Oct 6 (Mon) = school day")
assert(sps.isSchoolDay(d(2025, 10, 7)), "Oct 7 (Tue) = school day")
assert(sps.isSchoolDay(d(2025, 10, 8)), "Oct 8 (Wed) = school day")
assert(sps.isSchoolDay(d(2025, 10, 9)), "Oct 9 (Thu) = school day")
assert(!sps.isSchoolDay(d(2025, 10, 10)), "Oct 10 (Fri In-Service) ≠ school day")

// ============================================================
print("\n🏫 SCHOOL BOTTLE TRACKING TESTS")
print("=" * 50)

// Test: 5 pills entered Oct 13 (Mon, no holidays that week)
// Consumed on: Oct 14, 15, 16, 17, then weekend, Oct 20
let runOut1 = schoolDaysFromDate(d(2025, 10, 13), count: 5, calendar: sps)
assert(cal.startOfDay(for: runOut1) == d(2025, 10, 20),
       "5 pills from Oct 13 → runs out Oct 20 (skips weekend)")

// Test: skips Veterans Day
// 5 pills entered Nov 10 (Mon). Nov 11 is Veterans Day.
// School days: Nov 12 (1), 13 (2), 14 (3), weekend, Nov 17 (4), 18 (5)
let runOut2 = schoolDaysFromDate(d(2025, 11, 10), count: 5, calendar: sps)
assert(cal.startOfDay(for: runOut2) == d(2025, 11, 18),
       "5 pills from Nov 10 → runs out Nov 18 (skips Veterans Day)")

// Test: spans winter break
// 3 pills entered Dec 19 (Fri, last school day before break)
// Winter break Dec 22 - Jan 2, Jan 3-4 weekend
// Next school days: Jan 5 (1), 6 (2), 7 (3)
let runOut3 = schoolDaysFromDate(d(2025, 12, 19), count: 3, calendar: sps)
assert(cal.startOfDay(for: runOut3) == d(2026, 1, 7),
       "3 pills from Dec 19 → runs out Jan 7 (skips winter break)")

// Test: spans spring break
// 3 pills entered Apr 10 (Fri)
// Apr 13-17 spring break, Apr 18-19 weekend
// Next school days: Apr 20 (1), 21 (2), 22 (3)
let runOut4 = schoolDaysFromDate(d(2026, 4, 10), count: 3, calendar: sps)
assert(cal.startOfDay(for: runOut4) == d(2026, 4, 22),
       "3 pills from Apr 10 → runs out Apr 22 (skips spring break)")

// Test: 0 pills
let runOut5 = schoolDaysFromDate(Date(), count: 0, calendar: sps)
// With 0 count the loop doesn't execute, returns startOfDay
// Just check it doesn't crash
assert(true, "0 pills doesn't crash")

// ============================================================
print("\n" + "=" * 50)
print("📊 RESULTS: \(passed) passed, \(failed) failed")
if failed == 0 {
    print("🎉 ALL TESTS PASSED!")
} else {
    print("⚠️  Some tests failed — review above")
}
print("")

// Helper for string repeat
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
