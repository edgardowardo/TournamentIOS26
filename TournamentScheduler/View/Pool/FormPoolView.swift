import SwiftUI
import SwiftData

struct FormPoolView: View {
    
    static let keySeedControlStyle = "FormPoolView.seedControlStyle"
    
    let parent: Tournament?
    let item: Pool?
    let onDismiss: () -> Void

    @AppStorage(Self.keySeedControlStyle) private var seedControlStyle: SeedControlStyle = .horizontal
    @State private var isEditing = false
    
    init(parent: Tournament? = nil, item: Pool? = nil, onDismiss: @escaping () -> Void = {}) {
        self.parent = parent
        self.item = item
        self.onDismiss = onDismiss
        _name = State(initialValue: item?.name ?? "")
        _isHandicap = State(initialValue: item?.isHandicap ?? false)
        _isSeedsCopyable = State(initialValue: item?.isSeedsCopyable ?? true)
        _viewModel = StateObject(wrappedValue: ViewModel(item: item))
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var isShuffle: Bool = false
    @State private var isReset: Bool = false
    @State private var isHandicap: Bool
    @State private var isSeedsCopyable: Bool
    @State private var showCopySeeds: Bool = false
    @State private var showAlertCopySeeds: Bool = false
    @State private var selectedPoolForCopy: Pool?
    @Namespace private var animation
    @FocusState private var nameFieldFocused: Bool
    @StateObject private var viewModel: ViewModel
    private let sourceIDCopySeeds = "CopySeedsView"

    private var isAdd: Bool { item == nil }
    
    private var seedControlButtonsView: some View {
        HStack {

            Toggle(isOn: $isShuffle) {
                Image(systemName: "shuffle")
            }
            .toggleStyle(.button)
            .onChange(of: isShuffle) { _, newValue in
                shuffle()
                isShuffle = false
            }

            Spacer()
            
            Toggle(isOn: $isReset) {
                Image(systemName: "arrowshape.turn.up.backward")
            }
            .toggleStyle(.button)
            .onChange(of: isReset) { _, newValue in
                reset()
                isReset = false
            }

            Divider()

            Spacer()
            
            Toggle(isOn: $isSeedsCopyable) {
                Image(systemName: "document.on.document.fill")
            }
            .toggleStyle(.button)

            Spacer()
            
            Toggle(isOn: $isHandicap.animation(.bouncy)) {
                Image(systemName: "wheelchair")
            }
            .toggleStyle(.button)

            Spacer()
            
            Toggle(isOn: $isEditing.animation(.bouncy)) {
                Image(systemName: "arrow.up.arrow.down")
            }
            .toggleStyle(.button)
        }
    }
    
    private var sectionConfigureView: some View {
        Section (
            header: Text("Configure"),
            footer: Text("Copy seeds from other tournaments. To prevent seedings from being copied, deselect the copy document below. Handicap points calculate initial scores in matches.")
        ) {
            TextField("Name", text: $name)
                .focused($nameFieldFocused)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.scheduleType.description)
                
                Picker(selection: $viewModel.scheduleType.animation(.bouncy), label: EmptyView()) {
                    ForEach(Schedule.allCases, id: \.self) { item in
                        Image(systemName: item.sfSymbolName)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.scheduleType) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    viewModel.truncateSeedsIfNeeded()
                    
                    if viewModel.seedCount < newValue.minimumSeedCount {
                        viewModel.seedCount = newValue.minimumSeedCount
                    }
                }
            }
            
            Picker("Seed Count", selection: $viewModel.seedCount) {
                ForEach(viewModel.scheduleType.allowedSeedCounts, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .pickerStyle(.navigationLink)
            .onChange(of: viewModel.seedCount) { oldValue, newValue in
                viewModel.updatedSeedCount(from: oldValue, to: newValue)
            }
        }
    }
    
    private var sectionSeedsView: some View {
        Section(
            header: Text("Seeds")
        ) {
            
            if seedControlStyle == .vertical {
                Button("Shuffle") {
                    shuffle()
                }
                .buttonStyle(.plain)
                
                Button("Reset") {
                    reset()
                }
                .buttonStyle(.plain)
                
                Toggle("Copyable", isOn: $isSeedsCopyable)

                Toggle("Handicap", isOn: $isHandicap.animation(.bouncy))

                Toggle("Reorder", isOn: $isEditing.animation(.bouncy))
                
            } else if seedControlStyle == .horizontal {
                seedControlButtonsView
            }
            
            ForEach($viewModel.seedsViewModels) { $seed in
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
            .onMove { indices, newOffset in
                viewModel.seedsViewModels.move(fromOffsets: indices, toOffset: newOffset)
                viewModel.setSeeds()
            }
        }
        

    }
        
    var body: some View {
        NavigationStack {
            List {
                sectionConfigureView
                sectionSeedsView
            }
            .alert("Copy Seeds", isPresented: $showAlertCopySeeds.animation(.bouncy), actions: {
                Button("Override", role: .destructive) {
                    if let pool = selectedPoolForCopy {
                        withAnimation {
                            viewModel.overrideSeeds(from: pool)
                        }
                    }
                    selectedPoolForCopy = nil
                }
                Button("Add") {
                    if let pool = selectedPoolForCopy {
                        withAnimation {
                            viewModel.addSeeds(from: pool)
                        }
                    }
                    selectedPoolForCopy = nil
                }
                Button("Cancel", role: .cancel) {
                    selectedPoolForCopy = nil
                }
            }, message: {
                Text("Would you like to add or override the seeds?")
            })
            .navigationTitle("\(isAdd ? "New" : "Edit") Pool")
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .sheet(isPresented: $showCopySeeds, content: {
                CopySeedsView(onSave: { pool in
                    selectedPoolForCopy = pool
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showAlertCopySeeds = true
                    }
                })
                .interactiveDismissDisabled(true)
                .navigationTransition(.zoom(sourceID: sourceIDCopySeeds, in: animation))
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                        onDismiss()
                    }
                }
                
                ToolbarItem() {
                    Button {
                        copySeeds()
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                }
                .matchedTransitionSource(id: sourceIDCopySeeds, in: animation)
                
                ToolbarSpacer()
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", systemImage: "checkmark") {
                        if let item = item {
                            item.name = name
                            item.schedule = viewModel.scheduleType
                            item.seedCount = viewModel.seedCount
                            item.isHandicap = isHandicap
                            item.isSeedsCopyable = isSeedsCopyable
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
                                schedule: viewModel.scheduleType,
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
                            newItem.isSeedsCopyable = isSeedsCopyable
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
    
    private func shuffle() {
        viewModel.shuffle()
    }
        
    private func reset() {
        viewModel.reset()
    }
    
    private func copySeeds() {
        showCopySeeds = true
    }
}

#Preview {
    FormPoolView(parent: nil, item: nil) {}
}
