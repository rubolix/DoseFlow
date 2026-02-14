import SwiftUI
import SwiftData

struct DataSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingExportShare = false
    @State private var showingImportPicker = false
    @State private var showingImportConfirm = false
    @State private var showingResult = false
    @State private var resultMessage = ""
    @State private var resultIsError = false
    @State private var exportFileURL: URL?
    @State private var pendingImportURL: URL?

    var body: some View {
        List {
            Section {
                Button {
                    exportData()
                } label: {
                    Label("Export All Data", systemImage: "square.and.arrow.up")
                }

                Button {
                    showingImportPicker = true
                } label: {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                }
            } header: {
                Text("Backup & Restore")
            } footer: {
                Text("Export saves all your data as a JSON file. Import adds data from a previously exported file — it does not replace existing data.")
            }
        }
        .navigationTitle("Data")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExportShare) {
            if let url = exportFileURL {
                ShareSheet(url: url)
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportFile(result)
        }
        .alert("Import Data?", isPresented: $showingImportConfirm) {
            Button("Import", role: .destructive) {
                performImport()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will add all people, medications, and pickups from the backup file. Existing data will not be removed.")
        }
        .alert(resultIsError ? "Error" : "Success", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            Text(resultMessage)
        }
    }

    private func exportData() {
        do {
            let data = try DataManager.exportData(from: modelContext)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStr = formatter.string(from: Date())
            let fileName = "DoseFlow-Backup-\(dateStr).json"

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: tempURL)
            exportFileURL = tempURL
            showingExportShare = true
        } catch {
            resultMessage = "Failed to export: \(error.localizedDescription)"
            resultIsError = true
            showingResult = true
        }
    }

    private func handleImportFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            pendingImportURL = url
            showingImportConfirm = true
        case .failure(let error):
            resultMessage = "Failed to select file: \(error.localizedDescription)"
            resultIsError = true
            showingResult = true
        }
    }

    private func performImport() {
        guard let url = pendingImportURL else { return }
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "DoseFlow", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access the selected file."])
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let data = try Data(contentsOf: url)
            let result = try DataManager.importData(from: data, into: modelContext)
            resultMessage = "Imported \(result.people) people, \(result.medications) medications, and \(result.pickups) pickups."
            resultIsError = false
            showingResult = true
        } catch {
            resultMessage = "Failed to import: \(error.localizedDescription)"
            resultIsError = true
            showingResult = true
        }
        pendingImportURL = nil
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
