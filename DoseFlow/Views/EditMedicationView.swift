import SwiftUI

struct EditMedicationView: View {
    @Environment(\.dismiss) private var dismiss

    let medication: Medication
    @State private var name: String
    @State private var dosage: String
    @State private var pillsPerDay: Int
    @State private var isSchoolTracked: Bool

    init(medication: Medication) {
        self.medication = medication
        _name = State(initialValue: medication.name)
        _dosage = State(initialValue: medication.dosage)
        _pillsPerDay = State(initialValue: medication.pillsPerDay)
        _isSchoolTracked = State(initialValue: medication.isSchoolTracked)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 20mg)", text: $dosage)
                } header: {
                    Text("Medication")
                }

                Section {
                    Stepper("Pills per day: \(pillsPerDay)", value: $pillsPerDay, in: 1...5)
                } header: {
                    Text("Dosing")
                }

                Section {
                    Toggle("Track school bottle", isOn: $isSchoolTracked)
                } header: {
                    Text("School")
                }
            }
            .navigationTitle("Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        medication.name = name.trimmingCharacters(in: .whitespaces)
        medication.dosage = dosage.trimmingCharacters(in: .whitespaces)
        medication.pillsPerDay = pillsPerDay
        medication.isSchoolTracked = isSchoolTracked
        dismiss()
    }
}
