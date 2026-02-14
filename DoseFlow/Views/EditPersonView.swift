import SwiftUI

struct EditPersonView: View {
    @Environment(\.dismiss) private var dismiss

    let person: Person
    @State private var name: String
    @State private var selectedColor: String

    init(person: Person) {
        self.person = person
        _name = State(initialValue: person.name)
        _selectedColor = State(initialValue: person.colorHex)
    }

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
            .navigationTitle("Edit Person")
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
        person.name = name.trimmingCharacters(in: .whitespaces)
        person.colorHex = selectedColor
        dismiss()
    }
}
