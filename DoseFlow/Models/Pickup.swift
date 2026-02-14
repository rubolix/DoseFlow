import Foundation
import SwiftData

@Model
final class Pickup {
    var date: Date
    var pillCount: Int
    var medication: Medication?

    init(date: Date = .now, pillCount: Int) {
        self.date = date
        self.pillCount = pillCount
    }
}
