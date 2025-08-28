import SwiftUI
import SwiftData

struct FormPoolView: View {
    
    struct SeedViewModel: Identifiable {
        let id: Int
        var name: String
        var value: String
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var tourType: TourType
    @State private var seedCount: Int
    @State private var isHandicap: Bool
    @State private var isCanCopySeeds: Bool
    @State private var seedsViewModels: [SeedViewModel]
    @FocusState private var nameFieldFocused: Bool
    
    let parent: Tournament?
    let item: Pool?
    let onDismiss: () -> Void
    let isBooleansToggles = true
    
    var isAdd: Bool { item == nil }
    
    init(parent: Tournament? = nil, item: Pool? = nil, onDismiss: @escaping () -> Void = {}) {
        self.parent = parent
        self.item = item
        self.onDismiss = onDismiss
        _name = State(initialValue: item?.name ?? "")
        _tourType = State(initialValue: item?.tourType ?? .roundRobin)
        _seedCount = State(initialValue: item?.seedCount ?? 4)
        _isHandicap = State(initialValue: item?.isHandicap ?? false)
        _isCanCopySeeds = State(initialValue: item?.isSeedsCopyable ?? true)
        
        let initialSeedCount = item?.seedCount ?? 4
        let existingSeeds: [SeedViewModel]
        // Since item.seeds is unknown type, assuming no existing seeds, initialize empty seeds
        existingSeeds = (0..<initialSeedCount).map { SeedViewModel(id: $0 + 1, name: "Seed \($0 + 1)", value: "") }
        _seedsViewModels = State(initialValue: existingSeeds)
    }
    
    var optionsView: some View {
        HStack(spacing: 20) {
            
            Button(action: shuffle) {
                VStack {
                    Image(systemName: "shuffle")
                    Text("Shuffle")
                        .font(.caption)
                }
            }
            Spacer()
            Button(action: sort) {
                VStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Sort")
                        .font(.caption)
                }
            }
            Spacer()
            Button(action: reset) {
                VStack {
                    Image(systemName: "arrowshape.turn.up.backward")
                    Text("Reset")
                        .font(.caption)
                }
            }
            Spacer()
            Button(action: copySeeds) {
                VStack {
                    Image(systemName: "document.on.document")
                    Text("Copy")
                        .font(.caption)
                }
            }
        }
        .padding()
    }
    
    var sectionConfigureView: some View {
        Section (
            header: Text("Configure"),
            footer: Text("Copy seeds from other tournaments. To prevent seedings below from being copied, uncheck 'Can Copy Seeds'. Handicaps points are used in calculating seedings.")
            
        ) {
            TextField("Name", text: $name)
                .focused($nameFieldFocused)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(tourType.description)
                
                Picker(selection: $tourType, label: EmptyView()) {
                    ForEach(TourType.allCases, id: \.self) { item in
                        Image(systemName: item.sfSymbolName)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Picker("Seed Count", selection: $seedCount) {
                ForEach(tourType.allowedSeedCounts, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .pickerStyle(.navigationLink)
            
            if isBooleansToggles {
                Toggle("Can Copy Seeds", isOn: $isCanCopySeeds)
                
                Toggle("Handicaps", isOn: $isHandicap)
            } else {
                HStack {
                    Toggle(isOn: $isCanCopySeeds) {
                        VStack {
                            Image(systemName: "document.on.document.fill")
                            Text("Can Copy Seeds")
                                .font(.caption)
                        }
                        
                    }
                    .toggleStyle(.button)
                    
                    Spacer()
                    
                    Toggle(isOn: $isHandicap) {
                        VStack {
                            Image(systemName: "wheelchair")
                            Text("Handicap")
                                .font(.caption)
                        }
                        
                    }
                    .toggleStyle(.button)
                }
            }
        }
    }
    
    var sectionSeedsView: some View {
        Section(
            header: Text("Seeds")
        ) {
            ForEach($seedsViewModels) { $seed in
                HStack {
                    Text("\(seed.id).")
                        .foregroundStyle(.secondary)
                    Spacer()
                    TextField("Seed \(seed.id)", text: $seed.name)
                        .frame(maxWidth: .infinity)
                    Spacer()
                    TextField("0", text: $seed.value)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                sectionConfigureView
                sectionSeedsView
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
                                seedCount: seedCount,
                                isHandicap: isHandicap,
                                timestamp: .now,
                                tournament: parent,
                                participants: seedsViewModels.map {
                                    .init(name: $0.name,
                                          isHandicapped: isHandicap,
                                          handicapPoints: Int($0.value) ?? 0,
                                          seed: $0.id)
                                },
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
            nameFieldFocused = name.isEmpty
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .onChange(of: seedCount) { _, newValue in
            if newValue > seedsViewModels.count {
                let nextId = (seedsViewModels.last?.id ?? 0) + 1
                seedsViewModels.append(contentsOf: (0..<(newValue - seedsViewModels.count)).map { SeedViewModel(id: nextId + $0, name: "Seed \(nextId + $0)", value: "") })
            } else if newValue < seedsViewModels.count {
                seedsViewModels = Array(seedsViewModels.prefix(newValue))
            }
        }
    }
    
    private func shuffle() {
        print("shuffle")
    }
    
    private func sort() {
        print("sort")
    }
    
    private func reset() {
        print("reset")
    }
    
    private func copySeeds() {
        print("copySeeds")
    }
}

#Preview {
    FormPoolView(parent: nil, item: nil) {}
}
