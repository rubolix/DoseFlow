import SwiftUI

struct AddMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let person: Person
    @State private var name = ""
    @State private var dosage = ""
    @State private var pillsPerDay = 1
    @State private var isSchoolTracked = false

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
                } footer: {
                    Text("Enable this for afternoon medications kept at school. Tracks supply based on school days only.")
                }
            }
            .navigationTitle("Add Medication")
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
        let med = Medication(
            name: name.trimmingCharacters(in: .whitespaces),
            dosage: dosage.trimmingCharacters(in: .whitespaces),
            pillsPerDay: pillsPerDay,
            isSchoolTracked: isSchoolTracked
        )
        med.person = person
        modelContext.insert(med)
        dismiss()
    }
}
