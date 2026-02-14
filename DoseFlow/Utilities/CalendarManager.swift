import EventKit
import SwiftUI

class CalendarManager {
    static let shared = CalendarManager()
    private let store = EKEventStore()

    func requestAccess() async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    func addEvent(title: String, date: Date, notes: String? = nil) async -> Bool {
        guard await requestAccess() else { return false }

        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)
        event.notes = notes
        event.calendar = store.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(relativeOffset: -3600)) // 1 hour before

        do {
            try store.save(event, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }

    func addRefillReminders(for medication: Medication, personName: String) async -> (orderAdded: Bool, pickupAdded: Bool) {
        let orderResult: Bool
        let pickupResult: Bool

        if let orderDate = medication.orderDate {
            orderResult = await addEvent(
                title: "📋 Order \(medication.name) for \(personName)",
                date: orderDate,
                notes: "Time to call in the refill for \(medication.name) (\(medication.dosage)). Runs out in 7 days."
            )
        } else {
            orderResult = false
        }

        if let pickupDate = medication.earliestPickupDate {
            pickupResult = await addEvent(
                title: "💊 Pick up \(medication.name) for \(personName)",
                date: pickupDate,
                notes: "Earliest pickup date for \(medication.name) (\(medication.dosage)). Runs out in 4 days."
            )
        } else {
            pickupResult = false
        }

        return (orderResult, pickupResult)
    }
}
