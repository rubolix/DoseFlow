import SwiftUI

struct MedicationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let medication: Medication
    let personName: String
    @State private var showingLogPickup = false
    @State private var showingSchoolTracker = false
    @State private var showingEditMedication = false
    @State private var editingPickup: Pickup?
    @State private var calendarAlert: CalendarAlertType?

    enum CalendarAlertType: Identifiable {
        case success, failure, noDate
        var id: Self { self }
    }

    var body: some View {
        List {
            // Status section
            Section {
                if let _ = medication.latestPickup {
                    StatusRow(label: "Pills Remaining", value: "\(medication.pillsRemaining)", icon: "pills.fill")
                    StatusRow(label: "Days Remaining", value: "\(medication.daysRemaining)", icon: "clock.fill",
                              color: medication.daysRemaining <= 4 ? .red : medication.daysRemaining <= 7 ? .orange : .green)

                    if let runOut = medication.runOutDate {
                        StatusRow(label: "Runs Out", value: runOut.formatted(.dateTime.month(.abbreviated).day().year()), icon: "exclamationmark.triangle.fill", color: .red)
                    }
                    if let order = medication.orderDate {
                        StatusRow(label: "Order By", value: order.formatted(.dateTime.month(.abbreviated).day().year()), icon: "calendar.badge.clock", color: .orange)
                    }
                    if let pickup = medication.earliestPickupDate {
                        StatusRow(label: "Can Pick Up", value: pickup.formatted(.dateTime.month(.abbreviated).day().year()), icon: "bag.fill", color: .blue)
                    }
                } else {
                    Text("No pickup logged yet")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Current Supply")
            }

            // Calendar actions
            if medication.latestPickup != nil {
                Section {
                    Button {
                        addToCalendar()
                    } label: {
                        Label("Add Reminders to Calendar", systemImage: "calendar.badge.plus")
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Adds order date and earliest pickup date to your iPhone calendar.")
                }
            }

            // School tracking
            if medication.isSchoolTracked {
                Section {
                    if let bottle = medication.latestSchoolBottle {
                        let sps = SPSCalendar()
                        let remaining = bottle.schoolDaysRemaining(calendar: sps)
                        StatusRow(label: "School Pills Left", value: "\(remaining)", icon: "building.2.fill")
                        if let runOut = bottle.projectedRunOutDate(calendar: sps) {
                            StatusRow(label: "School Supply Runs Out", value: runOut.formatted(.dateTime.month(.abbreviated).day().year()), icon: "calendar", color: remaining <= 5 ? .red : .blue)
                        }
                    }
                    Button {
                        showingSchoolTracker = true
                    } label: {
                        Label("Update School Bottle", systemImage: "pencil")
                    }
                    if medication.latestSchoolBottle != nil {
                        Button(role: .destructive) {
                            deleteLatestSchoolBottle()
                        } label: {
                            Label("Remove School Entry", systemImage: "trash")
                        }
                    }
                } header: {
                    Text("School Supply")
                }
            }

            // Log pickup
            Section {
                Button {
                    showingLogPickup = true
                } label: {
                    Label("Log New Pickup", systemImage: "plus.circle.fill")
                }
            }

            // Pickup history
            if !medication.pickups.isEmpty {
                Section {
                    ForEach(medication.pickups.sorted(by: { $0.date > $1.date })) { pickup in
                        Button {
                            editingPickup = pickup
                        } label: {
                            HStack {
                                Text(pickup.date.formatted(.dateTime.month(.abbreviated).day().year()))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(pickup.pillCount) pills")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .onDelete(perform: deletePickups)
                } header: {
                    Text("Pickup History")
                } footer: {
                    Text("Tap to edit. Swipe left to delete.")
                }
            }
        }
        .navigationTitle(medication.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditMedication = true
                } label: {
                    Image(systemName: "pencil.circle")
                }
            }
        }
        .sheet(isPresented: $showingLogPickup) {
            LogPickupView(medication: medication)
        }
        .sheet(isPresented: $showingSchoolTracker) {
            SchoolBottleView(medication: medication)
        }
        .sheet(isPresented: $showingEditMedication) {
            EditMedicationView(medication: medication)
        }
        .sheet(item: $editingPickup) { pickup in
            EditPickupView(pickup: pickup)
        }
        .alert(item: $calendarAlert) { alertType in
            switch alertType {
            case .success:
                return Alert(title: Text("Added to Calendar"), message: Text("Order and pickup reminders have been added."), dismissButton: .default(Text("OK")))
            case .failure:
                return Alert(title: Text("Calendar Access Denied"), message: Text("Please enable calendar access in Settings to add reminders."), dismissButton: .default(Text("OK")))
            case .noDate:
                return Alert(title: Text("No Dates Available"), message: Text("Log a pickup first to generate reminder dates."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addToCalendar() {
        guard medication.orderDate != nil || medication.earliestPickupDate != nil else {
            calendarAlert = .noDate
            return
        }
        Task {
            let result = await CalendarManager.shared.addRefillReminders(for: medication, personName: personName)
            await MainActor.run {
                calendarAlert = (result.orderAdded || result.pickupAdded) ? .success : .failure
            }
        }
    }

    private func deletePickups(at offsets: IndexSet) {
        let sorted = medication.pickups.sorted(by: { $0.date > $1.date })
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }

    private func deleteLatestSchoolBottle() {
        if let bottle = medication.latestSchoolBottle {
            modelContext.delete(bottle)
        }
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }
}
