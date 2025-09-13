import SwiftUI
import SwiftData

enum PoolTab: Int {
    case rounds = 0
    case losers = 1
    case ranks = 10
    case charts = 20
}

private typealias RoundsPicker = FormAppSettingsView.RoundsPicker

struct PoolDetailView: View {
    @Bindable var item: Pool
    
    @AppStorage("PoolDetailView.roundsPicker") private var roundsPicker: RoundsPicker = .horizontal
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    @State private var containerWidth: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    @State private var filterRound = -1
    @State private var selectedTab: PoolTab = .rounds
    private let sourceIDEditPool = "PoolEdit"
        
    private func titleView(_ item: Pool) -> some View {
        VStack(alignment: .leading) {
            Text("\(item.name)")
                .font(.largeTitle.bold())
            Text("\(item.matchCount) matches, \(item.participants.count) seeds\(item.isHandicap ? " (handicapped)" : "")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                containerWidth = proxy.size.width
                                containerHeight = proxy.size.height
                            }
                            .onChange(of: proxy.size.width) { _, newValue in
                                containerWidth = newValue
                            }
                            .onChange(of: proxy.size.height) { _, newValue in
                                containerHeight = newValue
                            }
                    }
                )
            
            TabView(selection: $selectedTab) {
                Tab(tabText, systemImage: tabSymbolName, value: .rounds) {
                    RoundsView(rounds: item.rounds, availableWidth: containerWidth, filterRound: filterRound) {
                        titleView(item)
                    }
                }
                
                if item.schedule == .doubleElimination {
                    Tab("Losers", systemImage: item.schedule.sfSymbolName, value: .losers) {
                        RoundsView(rounds: item.losers, availableWidth: containerWidth, filterRound: filterRound) {
                            titleView(item)
                        }
                    }
                }
                
                Tab("Ranks", systemImage: "tablecells", value: .ranks) {
                    let vm = RanksViewModel(pool: item)
                    RanksView(vm: vm, isShowAllStats: true) {
                        titleView(item)
                    }
                }
                
                Tab("Insights", systemImage: "chart.pie", value : .charts) {
                    let vm = ChartsViewModel(pool: item)
                    ChartsView(vm: vm, minDimension: min(containerWidth, containerHeight) * 0.75) {
                        titleView(item)
                    }
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                switch selectedTab {
                case .rounds, .losers:
                    roundsPickerView
                case .ranks:
                    Text("Rankings")
                case .charts:
                    Text("Insights")
                }
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(item.tournament?.name ?? "Unknown")
        .navigationSubtitle("\(item.name) \(item.rounds.count) rounds")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit", systemImage: "square.and.pencil") {
                    showEditPool.toggle()
                }
            }
            .matchedTransitionSource(id: sourceIDEditPool, in: animationNamespace)
        }
        .sheet(isPresented: $showEditPool) {
            FormPoolView(item: item, onDismiss: { showEditPool = false })
                .interactiveDismissDisabled(true)
                .navigationTransition(.zoom(sourceID: sourceIDEditPool, in: animationNamespace))
        }
    }
    
    private var tabText: String {
        guard item.schedule == .doubleElimination else {
            return item.schedule.description
        }
        return "Winners"
    }
    
    private var tabSymbolName: String {
        guard item.schedule == .doubleElimination else {
            return item.schedule.sfSymbolName
        }
        return Schedule.singleElimination.sfSymbolName
    }
    
    private var pickerValues: [(Int, String)] {
        [(-1, "ALL")]
         + item
            .rounds
            .sorted { $0.value < $1.value }
            .map { ($0.value, "\($0.value)") }
    }
    
    private var roundsPickerView: some View {
        HStack {
            if roundsPicker == .horizontal {
                HorizontalPicker(values: pickerValues, selectedValue: $filterRound)
            } else {
                Menu {
                    ForEach(item.rounds.sorted { $0.value > $1.value }, id: \.self) { r in
                        Button("\(r.value)") {
                            withAnimation(.easeInOut) {
                                filterRound = r.value
                            }
                        }
                    }
                    Button("ALL", systemImage: "slider.horizontal.3") {
                        withAnimation(.easeInOut) {
                            filterRound = -1
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text(filterRound == -1 ? "ALL" : "Round \(filterRound)")
                    }
                }
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    let view: some View = {
        let container = try! ModelContainer(for: Pool.self)
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<Pool>()
        let allPool = (try? context.fetch(fetchDescriptor)) ?? []
        for pool in allPool { context.delete(pool) }
        let pool: Pool = .init(
            name: "Preliminaries",
            schedule: .roundRobin,
            timestamp: .now,
            tournament: nil,
            participants: [])
        let m1: Match = .init(index: 1, round: nil, left: .init(name: "David", seed: 1), right: .init(name: "Arthur", seed: 2))
        let m2: Match = .init(index: 2, round: nil, left: .init(name: "Pavel", seed: 3), right: .init(name: "Guidon", seed: 4))
        let r1: Round = .init(value: 1, pool: pool, matches: [m1, m2])
        pool.rounds = [ r1,
                        .init(value: 2, pool: pool, matches: []),
                        .init(value: 3, pool: pool, matches: []),
                        .init(value: 4, pool: pool, matches: []),
                        .init(value: 5, pool: pool, matches: []),
                        .init(value: 6, pool: pool, matches: []),
                        .init(value: 7, pool: pool, matches: []),
                        .init(value: 8, pool: pool, matches: []),
                        .init(value: 9, pool: pool, matches: []),
                        .init(value: 10, pool: pool, matches: []),
                        .init(value: 12, pool: pool, matches: []),
                        .init(value: 13, pool: pool, matches: []),
                        .init(value: 14, pool: pool, matches: []),
                        .init(value: 15, pool: pool, matches: []),
                        .init(value: 16, pool: pool, matches: []),
                        .init(value: 17, pool: pool, matches: [])
        ]
        context.insert(pool)
        return PoolDetailView(item: pool)
            .modelContainer(container)
    }()
    view
}

