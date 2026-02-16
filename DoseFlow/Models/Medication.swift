import Foundation
import SwiftData

@Model
final class Medication {
    var name: String
    var dosage: String
    var pillsPerDay: Int
    var isSchoolTracked: Bool
    var isArchived: Bool
    var archivedDate: Date?
    var person: Person?

    @Relationship(deleteRule: .cascade, inverse: \Pickup.medication)
    var pickups: [Pickup] = []

    @Relationship(deleteRule: .cascade, inverse: \SchoolBottle.medication)
    var schoolBottles: [SchoolBottle] = []

    init(name: String, dosage: String = "", pillsPerDay: Int = 1, isSchoolTracked: Bool = false) {
        self.name = name
        self.dosage = dosage
        self.pillsPerDay = pillsPerDay
        self.isSchoolTracked = isSchoolTracked
        self.isArchived = false
        self.archivedDate = nil
    }

    /// Most recent pickup
    var latestPickup: Pickup? {
        pickups.sorted { $0.date > $1.date }.first
    }

    /// Pills remaining based on latest pickup
    var pillsRemaining: Int {
        guard let pickup = latestPickup else { return 0 }
        let cal = Calendar.current
        let pickupDay = cal.startOfDay(for: pickup.date)
        let endDay = cal.startOfDay(for: isArchived ? (archivedDate ?? Date()) : Date())
        let daysSincePickup = cal.dateComponents([.day], from: pickupDay, to: endDay).day ?? 0
        let consumed = daysSincePickup * pillsPerDay
        return max(0, pickup.pillCount - consumed)
    }

    /// Date when pills will run out
    var runOutDate: Date? {
        guard let pickup = latestPickup, pillsPerDay > 0 else { return nil }
        if isArchived { return nil }
        let cal = Calendar.current
        let pickupDay = cal.startOfDay(for: pickup.date)
        let totalDays = pickup.pillCount / pillsPerDay
        return cal.date(byAdding: .day, value: totalDays, to: pickupDay)
    }

    /// Date to order refill (7 days before running out)
    var orderDate: Date? {
        guard let runOut = runOutDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: -7, to: runOut)
    }

    /// Earliest pickup date (4 days before running out)
    var earliestPickupDate: Date? {
        guard let runOut = runOutDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: -4, to: runOut)
    }

    /// Days until pills run out
    var daysRemaining: Int {
        guard let runOut = runOutDate else { return isArchived ? pillsRemaining : 0 }
        let today = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: today, to: runOut).day ?? 0
        return max(0, days)
    }

    /// Latest school bottle entry
    var latestSchoolBottle: SchoolBottle? {
        schoolBottles.sorted { $0.dateEntered > $1.dateEntered }.first
    }
}
