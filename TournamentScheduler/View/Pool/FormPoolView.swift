import SwiftUI
import SwiftData

struct FormPoolView: View {
    
    static let keySeedControlStyle = "FormPoolView.seedControlStyle"
    
    let parent: Tournament?
    let item: Pool?
    let onDismiss: () -> Void

    @AppStorage(Self.keySeedControlStyle) private var seedControlStyle: SeedControlStyle = .button
    @State private var isEditing = false
    
    init(parent: Tournament? = nil, item: Pool? = nil, onDismiss: @escaping () -> Void = {}) {
        self.parent = parent
        self.item = item
        self.onDismiss = onDismiss
        _name = State(initialValue: item?.name ?? "")
        _schedule = State(initialValue: item?.schedule ?? .roundRobin)
        _isHandicap = State(initialValue: item?.isHandicap ?? false)
        _isCanCopySeeds = State(initialValue: item?.isSeedsCopyable ?? true)
        _viewModel = StateObject(wrappedValue: ViewModel(item: item))
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var schedule: Schedule
    @State private var isHandicap: Bool
    @State private var isCanCopySeeds: Bool
    @FocusState private var nameFieldFocused: Bool
    @StateObject private var viewModel: ViewModel
    
    private var isAdd: Bool { item == nil }
    
    #warning("Use ExpandableGlassContainer")
    private var optionsView: some View {
        VStack(spacing: 20) {
            
            Button(action: shuffle) {
                VStack {
                    Image(systemName: "shuffle")
                    Text("Shuffle")
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
        .padding(.horizontal)
    }
    
    private var sectionConfigureView: some View {
        Section (
            header: Text("Configure"),
            footer: Text("Copy seeds from other tournaments. To prevent seedings below from being copied, uncheck 'Copyable'. Handicaps points are used in scheduling matches.")
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
                .onChange(of: schedule) { oldValue, newValue in
                    guard oldValue != newValue, !newValue.allowedSeedCounts.contains(viewModel.seedCount), oldValue == .americanDoubles || newValue == .americanDoubles  else { return }
                    viewModel.seedCount = 4
                }
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
            
            if seedControlStyle == .toggle {
                Toggle("Copyable", isOn: $isCanCopySeeds)
                
                Toggle("Reorder", isOn: $isEditing.animation(.bouncy))
                
                Toggle("Handicap", isOn: $isHandicap.animation(.bouncy))
            } else if seedControlStyle == .button {
                HStack {
                    Toggle(isOn: $isCanCopySeeds) {
                        VStack {
                            Image(systemName: "document.on.document.fill")
                            Text("Copyable")
                                .font(.caption)
                        }
                        
                    }
                    .toggleStyle(.button)
                    
                    Spacer()
                    
                    Toggle(isOn: $isEditing.animation(.bouncy)) {
                        VStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Reorder")
                                .font(.caption)
                        }
                    }
                    .toggleStyle(.button)
                    
                    Spacer()
                    
                    Toggle(isOn: $isHandicap.animation(.bouncy)) {
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
    
    private var sectionSeedsView: some View {
        Section(
            header: Text("Seeds")
        ) {
            ForEach($viewModel.seedsViewModels, editActions: .move) { $seed in
                HStack {
                    Text("\(seed.seed).")
                        .frame(idealWidth: 40)
                        .foregroundStyle(.secondary)
                    Spacer()
                    TextField("Seed \(seed.seed)", text: $seed.name)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .textInputAutocapitalization(.words)
                    
                    if isHandicap {
                        Spacer()
                        TextField("0", text: $seed.handicapPoints)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .keyboardType(.numberPad)
                    }
                }
                .frame(idealHeight: 15)
                .submitLabel(.done)
                .listRowSeparator(.hidden)
            }
        }
        

    }
        
    var body: some View {
        NavigationStack {
            List {
                sectionConfigureView
                sectionSeedsView
            }
            .navigationTitle("\(isAdd ? "New" : "Edit") Pool")
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .onChange(of: viewModel.seedsViewModels, { _, newValue in
                var seed = 1
                for s in newValue {
                    s.seed = seed
                    seed += 1
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                        onDismiss()
                    }
                }
                
                ToolbarSpacer()

                ToolbarItem {
                    Button("Options", systemImage: "ellipsis") {
                        withAnimation {
                            
                        }
                    }
                }
                
                ToolbarSpacer()
                
                ToolbarItem {
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
                                      handicapPoints: Int($0.handicapPoints) ?? 0,
                                      seed: $0.seed)
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
                                          handicapPoints: Int($0.handicapPoints) ?? 0,
                                          seed: $0.seed)
                                })
                            ScheduleBuilder(pool: newItem).schedule()
                            modelContext.insert(newItem)
                            Task { @MainActor in
                                try modelContext.save()
                            }
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
    
    #warning("Remove these functions")
    private func shuffle() {
        viewModel.seedsViewModels.shuffle()
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
