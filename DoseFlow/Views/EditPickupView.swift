import SwiftUI

struct EditPickupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let pickup: Pickup
    @State private var date: Date
    @State private var pillCount: Int

    init(pickup: Pickup) {
        self.pickup = pickup
        _date = State(initialValue: pickup.date)
        _pillCount = State(initialValue: pickup.pillCount)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Pickup Date", selection: $date, displayedComponents: .date)
                } header: {
                    Text("When")
                }

                Section {
                    HStack {
                        Text("Pill Count")
                        Spacer()
                        TextField("Count", value: $pillCount, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                } header: {
                    Text("How Many")
                }
            }
            .navigationTitle("Edit Pickup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(pillCount <= 0)
                }
            }
        }
    }

    private func save() {
        pickup.date = date
        pickup.pillCount = pillCount
        dismiss()
    }
}
