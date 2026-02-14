import SwiftUI
import SwiftData

struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let person: Person
    @State private var showingAddMed = false
    @State private var showingEditPerson = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        List {
            Section {
                if person.medications.isEmpty {
                    Text("No medications yet. Tap + to add one.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedMedications) { med in
                        NavigationLink(destination: MedicationDetailView(medication: med, personName: person.name)) {
                            MedicationListRow(medication: med)
                        }
                    }
                    .onDelete(perform: deleteMedications)
                }
            } header: {
                Text("Medications")
            }
        }
        .navigationTitle(person.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { showingAddMed = true } label: {
                        Label("Add Medication", systemImage: "plus")
                    }
                    Button { showingEditPerson = true } label: {
                        Label("Edit Person", systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) { showingDeleteConfirm = true } label: {
                        Label("Delete Person", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddMed) {
            AddMedicationView(person: person)
        }
        .sheet(isPresented: $showingEditPerson) {
            EditPersonView(person: person)
        }
        .alert("Delete \(person.name)?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(person)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all of \(person.name)'s medications and pickup history. This cannot be undone.")
        }
    }

    private var sortedMedications: [Medication] {
        person.medications.sorted { $0.daysRemaining < $1.daysRemaining }
    }

    private func deleteMedications(at offsets: IndexSet) {
        for index in offsets {
            let med = sortedMedications[index]
            modelContext.delete(med)
        }
    }
}

struct MedicationListRow: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(medication.name)
                    .font(.headline)
                if medication.isSchoolTracked {
                    Image(systemName: "building.2")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                Spacer()
                if medication.latestPickup != nil {
                    urgencyBadge
                }
            }

            if !medication.dosage.isEmpty {
                Text(medication.dosage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let pickup = medication.latestPickup {
                HStack(spacing: 16) {
                    Label("\(medication.pillsRemaining) pills left", systemImage: "pills")
                    if let orderDate = medication.orderDate {
                        Label("Order \(orderDate.formatted(.dateTime.month(.abbreviated).day()))", systemImage: "calendar.badge.clock")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var urgencyBadge: some View {
        let days = medication.daysRemaining
        let color: Color = days <= 4 ? .red : days <= 7 ? .orange : .green
        let label = days <= 0 ? "OUT" : "\(days)d"

        return Text(label)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}
