import SwiftUI

struct SchoolBottleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let medication: Medication
    @State private var pillCount = 20
    @State private var dateEntered = Date()

    private let spsCalendar = SPSCalendar()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Pills in Bottle")
                        Spacer()
                        TextField("Count", value: $pillCount, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    DatePicker("As of Date", selection: $dateEntered, displayedComponents: .date)
                } header: {
                    Text("School Bottle")
                } footer: {
                    Text("Enter the number of pills currently in the bottle at school.")
                }

                Section {
                    let projected = projectedRunOut()
                    let schoolDays = pillCount

                    HStack {
                        Text("School Days of Supply")
                        Spacer()
                        Text("\(schoolDays)")
                            .foregroundStyle(.secondary)
                    }
                    if let runOut = projected {
                        HStack {
                            Text("Projected Run Out")
                            Spacer()
                            Text(runOut.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                                .foregroundStyle(schoolDays <= 5 ? .red : .blue)
                        }
                    }
                } header: {
                    Text("Preview (School Days Only)")
                } footer: {
                    Text("Based on Seattle Public Schools 2025-2026 calendar. Excludes weekends, holidays, and breaks.")
                }
            }
            .navigationTitle("School Supply")
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

    private func projectedRunOut() -> Date? {
        guard pillCount > 0 else { return nil }
        let cal = Calendar.current
        var count = 0
        var date = cal.startOfDay(for: dateEntered)

        while count < pillCount {
            date = cal.date(byAdding: .day, value: 1, to: date)!
            if spsCalendar.isSchoolDay(date) {
                count += 1
            }
            // Safety: don't loop past end of school year + buffer
            if date > cal.date(byAdding: .year, value: 1, to: dateEntered)! { break }
        }
        return date
    }

    private func save() {
        let bottle = SchoolBottle(pillCount: pillCount, dateEntered: dateEntered)
        bottle.medication = medication
        modelContext.insert(bottle)
        dismiss()
    }
}
