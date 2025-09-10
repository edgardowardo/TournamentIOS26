import SwiftUI
import SwiftData

struct FormTournamentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var tags: String
    @State private var sport: Sport
    
    @FocusState private var nameFieldFocused: Bool
    
    let tournament: Tournament?
    let onDismiss: () -> Void

    var isAdd: Bool { tournament == nil }
    
    init(tournament: Tournament? = nil, onDismiss: @escaping () -> Void = {}) {
        self.tournament = tournament
        self.onDismiss = onDismiss
        _name = State(initialValue: tournament?.name ?? "")
        _tags = State(initialValue: tournament?.tags ?? "")
        _sport = State(initialValue: tournament?.sport ?? .unknown)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text("Details"),
                    footer: Text("Tags are lists of categories such as \"League\", \"Cup\", \"U-20\", etc. They configure your main screen in the app settings.")
                ) {
                    TextField("Name", text: $name)
                        .focused($nameFieldFocused)
                    TextField("Tags", text: $tags)
                }
                .textInputAutocapitalization(.words)
                
                Section(header: Text("Type")) {
                    Picker("Select", selection: $sport) {
                        ForEach(Sport.allCases, id: \.self) { item in
                            Label(item.rawValue.capitalized,
                                  systemImage: item.sfSymbolName)
                            .tag(item)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("\(isAdd ? "New" : "Edit") Tournament")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", systemImage: "checkmark") {
                        if isAdd {
                            let newTournament = Tournament(timestamp: Date())
                            newTournament.name = name
                            newTournament.tags = tags
                            newTournament.sport = sport
                            modelContext.insert(newTournament)
                        } else if let tournament = tournament {
                            tournament.timestamp = .now
                            tournament.name = name
                            tournament.tags = tags
                            tournament.sport = sport
                        }
                        dismiss()
                        onDismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            nameFieldFocused = true
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
}

#Preview {
    FormTournamentView(tournament: nil) {}
}
