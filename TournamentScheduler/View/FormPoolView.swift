import SwiftUI
import SwiftData

struct FormPoolView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
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
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($nameFieldFocused)
                        .textInputAutocapitalization(.words)
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
                                tourType: .doubleElimination,
                                timestamp: .now,
                                tournament: parent,
                                participants: [],
                                matches: [])
                            modelContext.insert(newItem)
                            parent?.pools.append(newItem)
                        } else if let item = item {
                            item.name = name
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
    FormPoolView(parent: nil, item: nil) {}
}
