import SwiftUI

struct PersonCard: View {
    let person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: person.colorHex))
                    .frame(width: 12, height: 12)
                Text(person.name)
                    .font(.headline)
                Spacer()
                Text("\(person.medications.count) meds")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if person.medications.isEmpty {
                Text("No medications added")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(person.medications.sorted(by: { $0.daysRemaining < $1.daysRemaining })) { med in
                    MedicationRow(medication: med)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !medication.dosage.isEmpty {
                    Text(medication.dosage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if medication.latestPickup != nil {
                HStack(spacing: 4) {
                    Text("\(medication.daysRemaining)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(urgencyColor)
                    Text("days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No pickup logged")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var urgencyColor: Color {
        let days = medication.daysRemaining
        if days <= 4 {
            return .red
        } else if days <= 7 {
            return .orange
        } else {
            return .green
        }
    }
}
