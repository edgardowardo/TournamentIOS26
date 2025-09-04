import SwiftUI
import SwiftData

struct PoolDetailView: View {
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    @State private var containerWidth: CGFloat = 0
    @State private var filterRound = 1
    @State private var selectedTab: Int = 0
    
    private let sourceIDEditPool = "PoolEdit"
    
    let item: Pool
        
    var body: some View {
        NavigationStack {
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
                    Tab(item.schedule.description, systemImage: item.schedule.sfSymbolName, value: 0) {
                        RoundsView(rounds: item.rounds, availableWidth: containerWidth, filterRound: filterRound)
                    }
                    
                    Tab("Standings", systemImage: "tablecells", value: 10) {
                        StandingsView(vm: .init(pool: item))
                    }
                                        
                    Tab("Charts", systemImage: "chart.pie", value : 20) {
                        ScrollView {
                            VStack {
                                Text("Replace Charts")
                                    .frame(maxWidth: .infinity, minHeight: 600, alignment: .top)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory {
                    if selectedTab == 0 {
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
                    } else {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                UITextField.appearance().clearButtonMode = .whileEditing
            }

            .navigationTitle(item.name)
            .navigationSubtitle(Text("\(item.rounds.count) rounds, \(item.matchCount) matches, \(item.participants.count) seeds\(item.isHandicap ? " (handicapped)" : "")"))
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
        return PoolDetailView(item: pool)
            .modelContainer(container)
    }()
    view
}

