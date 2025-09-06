import SwiftUI
import SwiftData

enum PoolTab: Int {
    case rounds = 0
    case ranks = 10
    case charts = 20
}

struct PoolDetailView: View {
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    @State private var containerWidth: CGFloat = 0
    @State private var filterRound = 1
    @State private var selectedTab: PoolTab = .rounds
    @Query private var pools: [Pool]
    
    private let sourceIDEditPool = "PoolEdit"
    
    let initem: Pool
        
    func titleView(_ item: Pool) -> some View {
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
        let item = pools.first(where: { $0 == initem })!
        ZStack {
            Color.clear
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { containerWidth = proxy.size.width }
                            .onChange(of: proxy.size.width) { _, newValue in
                                containerWidth = newValue
                            }
                    }
                )
            
            TabView(selection: $selectedTab) {
                Tab(item.schedule.description, systemImage: item.schedule.sfSymbolName, value: .rounds) {
                    RoundsView(rounds: item.rounds, availableWidth: containerWidth, filterRound: filterRound) {
                        titleView(item)
                    }
                }
                
                Tab("Ranks", systemImage: "tablecells", value: .ranks) {
                    let vm = RanksViewModel(pool: item)
                    RanksView(vm: vm, isShowAllStats: true) {
                        titleView(item)
                    }
                }
                
                Tab("Charts", systemImage: "chart.pie", value : .charts) {
                    let vm = ChartsViewModel(pool: item)
                    ChartsView(vm: vm) {
                        titleView(item)
                    }
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                if selectedTab == .rounds {
                    Menu {
                        ForEach(item.rounds.sorted { $0.value > $1.value }, id: \.self) { r in
                            Button("\(r.value)") {
                                withAnimation(.easeInOut) {
                                    filterRound = r.value
                                }
                            }
                        }
                        Button("All Rounds", systemImage: "slider.horizontal.3") {
                            withAnimation(.easeInOut) {
                                filterRound = -1
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text(filterRound == -1 ? "All Rounds" : "Round \(filterRound)")
                        }
                    }
                } else if selectedTab == .ranks {
                    Text("Ranks View")
                    EmptyView()
                } else if selectedTab == .charts {
                    Text("Charts View")
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
                       .init(value: 3, pool: pool, matches: [])]
        context.insert(pool)
        return PoolDetailView(initem: pool)
            .modelContainer(container)
    }()
    view
}

