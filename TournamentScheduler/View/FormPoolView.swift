import SwiftUI
import SwiftData

struct FormPoolView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var schedule: Schedule
    @State private var isHandicap: Bool
    @State private var isCanCopySeeds: Bool
    @FocusState private var nameFieldFocused: Bool
    
    @StateObject private var viewModel: FormPoolViewModel
    
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
        _schedule = State(initialValue: item?.schedule ?? .roundRobin)
        _isHandicap = State(initialValue: item?.isHandicap ?? false)
        _isCanCopySeeds = State(initialValue: item?.isSeedsCopyable ?? true)
        _viewModel = StateObject(wrappedValue: FormPoolViewModel(item: item))
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
            footer: Text("Copy seeds from other tournaments. To prevent seedings below from being copied, uncheck 'Can Copy Seeds'. Handicaps points are used in scheduling matches.")
        ) {
            TextField("Name", text: $name)
                .focused($nameFieldFocused)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(schedule.description)
                
                Picker(selection: $schedule, label: EmptyView()) {
                    ForEach(Schedule.allCases, id: \.self) { item in
                        Image(systemName: item.sfSymbolName)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Picker("Seed Count", selection: $viewModel.seedCount) {
                ForEach(schedule.allowedSeedCounts, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: viewModel.seedCount) { oldValue, newValue in
                viewModel.updatedSeedCount(from: oldValue, to: newValue)
            }
            
            if isBooleansToggles {
                Toggle("Can Copy Seeds", isOn: $isCanCopySeeds)
                
                Toggle("Handicap", isOn: $isHandicap)
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
            ForEach($viewModel.seedsViewModels) { $seed in
                HStack {
                    Text("\(seed.id).")
                        .frame(idealWidth: 40)
                        .foregroundStyle(.secondary)
                    Spacer()
                    TextField("Seed \(seed.id)", text: $seed.name)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .textInputAutocapitalization(.words)
                    Spacer()
                    TextField("0", text: $seed.value)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .keyboardType(.numberPad)
                }
                .submitLabel(.done)
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
                        if let item = item {
                            item.name = name
                            item.schedule = schedule
                            item.seedCount = viewModel.seedCount
                            item.isHandicap = isHandicap
                            item.timestamp = .now
                            item.participants = viewModel.seedsViewModels.map {
                                .init(name: $0.name,
                                      isHandicapped: isHandicap,
                                      handicapPoints: Int($0.value) ?? 0,
                                      seed: $0.id)
                            }
                            item.tournament?.timestamp = .now
                            item.rounds.removeAll()
                            ScheduleBuilder(pool: item).schedule()
                        } else {
                            let newItem: Pool = .init(
                                name: name,
                                schedule: schedule,
                                seedCount: viewModel.seedCount,
                                isHandicap: isHandicap,
                                timestamp: .now,
                                tournament: parent,
                                participants: viewModel.seedsViewModels.map {
                                    .init(name: $0.name,
                                          isHandicapped: isHandicap,
                                          handicapPoints: Int($0.value) ?? 0,
                                          seed: $0.id)
                                })
                            ScheduleBuilder(pool: newItem).schedule()
                            modelContext.insert(newItem)
                            parent?.timestamp = .now
                        }
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
