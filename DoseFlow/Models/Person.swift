import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var colorHex: String
    @Relationship(deleteRule: .cascade, inverse: \Medication.person)
    var medications: [Medication] = []

    init(name: String, colorHex: String = "#6A9FD4") {
        self.name = name
        self.colorHex = colorHex
    }
}
