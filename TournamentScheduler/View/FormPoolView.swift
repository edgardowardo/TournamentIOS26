import SwiftUI
import SwiftData

struct FormPoolView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var tourType: TourType
    @State private var count: Int
    @State private var isHandicap: Bool
    @State private var isSeedsImportable: Bool
    @FocusState private var nameFieldFocused: Bool
    
    let parent: Tournament?
    let item: Pool?
    let onDismiss: () -> Void
    
    var isAdd: Bool { item == nil }
    
    init(parent: Tournament? = nil, item: Pool? = nil, onDismiss: @escaping () -> Void = {}) {
        self.parent = parent
        self.item = item
        self.onDismiss = onDismiss
        _name = State(initialValue: item?.name ?? "")
        _tourType = State(initialValue: item?.tourType ?? .roundRobin)
        _count = State(initialValue: item?.count ?? 4)
        _isHandicap = State(initialValue: item?.isHandicap ?? false)
        _isSeedsImportable = State(initialValue: item?.isSeedsImportable ?? true)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section (
                    header: Text("Configure"),
                    footer: Text("You can import seedings from other tournaments. If you hide seeds for this pool, it will hide from pool imports to prevent clutter.")

                ) {
                    TextField("Name", text: $name)
                        .focused($nameFieldFocused)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Picker(selection: $tourType, label: EmptyView()) {
                            ForEach(TourType.allCases, id: \.self) { item in
                                Image(systemName: item.sfSymbolName)
                            }
                        }
                        .pickerStyle(.segmented)

                        Text(tourType.description)
                    }
                    
                    
                    Picker("Seed Count", selection: $count) {
                        ForEach(tourType.allowedTeamCounts, id: \.self) { item in
                            Text("\(item)")
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    
                }
            }
            .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing
            }
            .navigationTitle("\(isAdd ? "New" : "Edit") Pool")
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
                            let newItem: Pool = .init(
                                name: name,
                                tourType: tourType,
                                count: count,
                                isHandicap: isHandicap,
                                timestamp: .now,
                                tournament: parent,
                                participants: [],
                                matches: [])
                            modelContext.insert(newItem)
                            parent?.pools.append(newItem)
                        } else if let item = item {
                            item.name = name
                        }
                        parent?.timestamp = .now
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
    FormPoolView(parent: nil, item: nil) {}
}
