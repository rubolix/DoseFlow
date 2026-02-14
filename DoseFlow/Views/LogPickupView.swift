import SwiftUI

struct LogPickupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let medication: Medication
    @State private var date = Date()
    @State private var pillCount = 30

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
                } footer: {
                    Text("Enter the exact number of pills picked up.")
                }

                Section {
                    let daysSupply = pillCount / max(medication.pillsPerDay, 1)
                    let runOut = Calendar.current.date(byAdding: .day, value: daysSupply, to: date)
                    let orderBy = Calendar.current.date(byAdding: .day, value: -7, to: runOut ?? date)
                    let pickupBy = Calendar.current.date(byAdding: .day, value: -4, to: runOut ?? date)

                    HStack {
                        Text("Days Supply")
                        Spacer()
                        Text("\(daysSupply) days")
                            .foregroundStyle(.secondary)
                    }
                    if let runOut {
                        HStack {
                            Text("Runs Out")
                            Spacer()
                            Text(runOut.formatted(.dateTime.month(.abbreviated).day().year()))
                                .foregroundStyle(.red)
                        }
                    }
                    if let orderBy {
                        HStack {
                            Text("Order By")
                            Spacer()
                            Text(orderBy.formatted(.dateTime.month(.abbreviated).day().year()))
                                .foregroundStyle(.orange)
                        }
                    }
                    if let pickupBy {
                        HStack {
                            Text("Can Pick Up")
                            Spacer()
                            Text(pickupBy.formatted(.dateTime.month(.abbreviated).day().year()))
                                .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Log Pickup")
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
        let pickup = Pickup(date: date, pillCount: pillCount)
        pickup.medication = medication
        modelContext.insert(pickup)
        dismiss()
    }
}
