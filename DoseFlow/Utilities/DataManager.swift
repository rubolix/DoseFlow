import Foundation
import SwiftData

// MARK: - Codable Transfer Objects

struct DoseFlowBackup: Codable {
    let version: Int
    let exportDate: Date
    let people: [PersonData]

    struct PersonData: Codable {
        let name: String
        let colorHex: String
        let medications: [MedicationData]
    }

    struct MedicationData: Codable {
        let name: String
        let dosage: String
        let pillsPerDay: Int
        let isSchoolTracked: Bool
        let isArchived: Bool
        let archivedDate: Date?
        let pickups: [PickupData]
        let schoolBottles: [SchoolBottleData]
    }

    struct PickupData: Codable {
        let date: Date
        let pillCount: Int
    }

    struct SchoolBottleData: Codable {
        let pillCount: Int
        let dateEntered: Date
    }
}

// MARK: - Export / Import

struct DataManager {

    static func exportData(from context: ModelContext) throws -> Data {
        let descriptor = FetchDescriptor<Person>(sortBy: [SortDescriptor(\.name)])
        let people = try context.fetch(descriptor)

        let backup = DoseFlowBackup(
            version: 1,
            exportDate: Date(),
            people: people.map { person in
                DoseFlowBackup.PersonData(
                    name: person.name,
                    colorHex: person.colorHex,
                    medications: person.medications.map { med in
                        DoseFlowBackup.MedicationData(
                            name: med.name,
                            dosage: med.dosage,
                            pillsPerDay: med.pillsPerDay,
                            isSchoolTracked: med.isSchoolTracked,
                            isArchived: med.isArchived,
                            archivedDate: med.archivedDate,
                            pickups: med.pickups.sorted { $0.date > $1.date }.map { pickup in
                                DoseFlowBackup.PickupData(date: pickup.date, pillCount: pickup.pillCount)
                            },
                            schoolBottles: med.schoolBottles.sorted { $0.dateEntered > $1.dateEntered }.map { bottle in
                                DoseFlowBackup.SchoolBottleData(pillCount: bottle.pillCount, dateEntered: bottle.dateEntered)
                            }
                        )
                    }
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(backup)
    }

    static func importData(from data: Data, into context: ModelContext) throws -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(DoseFlowBackup.self, from: data)

        var peopleCount = 0
        var medsCount = 0
        var pickupsCount = 0

        for personData in backup.people {
            let person = Person(name: personData.name, colorHex: personData.colorHex)
            context.insert(person)
            peopleCount += 1

            for medData in personData.medications {
                let med = Medication(
                    name: medData.name,
                    dosage: medData.dosage,
                    pillsPerDay: medData.pillsPerDay,
                    isSchoolTracked: medData.isSchoolTracked
                )
                med.isArchived = medData.isArchived
                med.archivedDate = medData.archivedDate
                med.person = person
                context.insert(med)
                medsCount += 1

                for pickupData in medData.pickups {
                    let pickup = Pickup(date: pickupData.date, pillCount: pickupData.pillCount)
                    pickup.medication = med
                    context.insert(pickup)
                    pickupsCount += 1
                }

                for bottleData in medData.schoolBottles {
                    let bottle = SchoolBottle(pillCount: bottleData.pillCount, dateEntered: bottleData.dateEntered)
                    bottle.medication = med
                    context.insert(bottle)
                }
            }
        }

        return ImportResult(people: peopleCount, medications: medsCount, pickups: pickupsCount)
    }

    struct ImportResult {
        let people: Int
        let medications: Int
        let pickups: Int
    }
}
