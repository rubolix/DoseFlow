import SwiftUI

struct AddPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedColor = PersonColors.options[0].hex

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                } header: {
                    Text("Person")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(PersonColors.options, id: \.hex) { option in
                            Circle()
                                .fill(Color(hex: option.hex))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == option.hex ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = option.hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("Add Person")
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
        let person = Person(name: name.trimmingCharacters(in: .whitespaces), colorHex: selectedColor)
        modelContext.insert(person)
        dismiss()
    }
}
