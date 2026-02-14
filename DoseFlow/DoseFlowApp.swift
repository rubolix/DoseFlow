import SwiftUI
import SwiftData

@main
struct DoseFlowApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(for: [Person.self, Medication.self, Pickup.self, SchoolBottle.self])
    }
}
