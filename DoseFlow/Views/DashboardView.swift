import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Person.name) private var people: [Person]
    @State private var showingAddPerson = false
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack {
            ScrollView {
                if people.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(people) { person in
                            NavigationLink(destination: PersonDetailView(person: person)) {
                                PersonCard(person: person)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .id(refreshID)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("DoseFlow")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPerson = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    refreshID = UUID()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "pills.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No family members yet")
                .font(.title2)
                .fontWeight(.medium)
            Text("Tap + to add a person and start\ntracking their medications.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Add Person") {
                showingAddPerson = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}
