import XCTest
@testable import DoseFlow

final class MedicationTests: XCTestCase {

    // MARK: - Pills Remaining

    func testPillsRemainingBasic() {
        let med = Medication(name: "Adderall", dosage: "20mg", pillsPerDay: 1)
        let pickup = Pickup(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        XCTAssertEqual(med.pillsRemaining, 20, "Should have 20 pills left after 10 days of 30")
    }

    func testPillsRemainingZeroFloor() {
        let med = Medication(name: "Ritalin", dosage: "10mg", pillsPerDay: 1)
        let pickup = Pickup(date: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        XCTAssertEqual(med.pillsRemaining, 0, "Should not go below 0")
    }

    func testPillsRemainingNoPickup() {
        let med = Medication(name: "Vyvanse", dosage: "30mg", pillsPerDay: 1)
        XCTAssertEqual(med.pillsRemaining, 0, "Should be 0 with no pickup")
    }

    func testPillsRemainingTodayPickup() {
        let med = Medication(name: "Concerta", dosage: "36mg", pillsPerDay: 1)
        let pickup = Pickup(date: Date(), pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        XCTAssertEqual(med.pillsRemaining, 30, "Same-day pickup should show full count")
    }

    // MARK: - Run Out Date

    func testRunOutDate() {
        let med = Medication(name: "Adderall", dosage: "20mg", pillsPerDay: 1)
        let today = Calendar.current.startOfDay(for: Date())
        let pickup = Pickup(date: today, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        let expected = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        XCTAssertEqual(med.runOutDate, expected, "Should run out in 30 days")
    }

    // MARK: - Order Date (7 days before run out)

    func testOrderDate() {
        let med = Medication(name: "Adderall", dosage: "20mg", pillsPerDay: 1)
        let today = Calendar.current.startOfDay(for: Date())
        let pickup = Pickup(date: today, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        let runOut = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        let expected = Calendar.current.date(byAdding: .day, value: -7, to: runOut)!
        XCTAssertEqual(med.orderDate, expected, "Order date should be 7 days before run out")
    }

    // MARK: - Earliest Pickup Date (4 days before run out)

    func testEarliestPickupDate() {
        let med = Medication(name: "Adderall", dosage: "20mg", pillsPerDay: 1)
        let today = Calendar.current.startOfDay(for: Date())
        let pickup = Pickup(date: today, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        let runOut = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        let expected = Calendar.current.date(byAdding: .day, value: -4, to: runOut)!
        XCTAssertEqual(med.earliestPickupDate, expected, "Pickup date should be 4 days before run out")
    }

    // MARK: - Days Remaining

    func testDaysRemaining() {
        let med = Medication(name: "Adderall", dosage: "20mg", pillsPerDay: 1)
        let today = Calendar.current.startOfDay(for: Date())
        let pickup = Pickup(date: today, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        XCTAssertEqual(med.daysRemaining, 30, "Should have 30 days remaining")
    }

    func testDaysRemainingExpired() {
        let med = Medication(name: "Ritalin", dosage: "10mg", pillsPerDay: 1)
        let pickup = Pickup(date: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, pillCount: 30)
        pickup.medication = med
        med.pickups = [pickup]

        XCTAssertEqual(med.daysRemaining, 0, "Should not go below 0")
    }

    // MARK: - Latest Pickup (uses most recent)

    func testLatestPickupUsedForCalculation() {
        let med = Medication(name: "Adderall", dosage: "20mg", pillsPerDay: 1)
        let oldPickup = Pickup(date: Calendar.current.date(byAdding: .day, value: -60, to: Date())!, pillCount: 30)
        let newPickup = Pickup(date: Date(), pillCount: 90)
        oldPickup.medication = med
        newPickup.medication = med
        med.pickups = [oldPickup, newPickup]

        XCTAssertEqual(med.pillsRemaining, 90, "Should use the most recent pickup")
        XCTAssertEqual(med.daysRemaining, 90)
    }
}
