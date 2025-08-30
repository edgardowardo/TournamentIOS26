import SwiftUI
import SwiftData

struct PoolDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Round.value) private var rounds: [Round]
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    
    private let sourceIDEditPool = "PoolEdit"
    
    let item: Pool
    
    var body: some View {
        let filteredRounds = rounds.filter { $0.pool == item }
        NavigationStack {
            TabView {
                Tab(item.schedule.description, systemImage: item.schedule.sfSymbolName) {
                    TabView {
                        ForEach(filteredRounds) { round in
                            Tab {
                                VStack(alignment: .center, spacing: 10) {
                                    Text("ROUND \(round.value)")
                                        .font(.title)
                                    
                                    ForEach(round.matches.sorted { $0.index < $1.index }) { match in
                                        HStack {
                                            Button(match.leftName) {
                                                print("winner is \(match.leftName)")
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(match.index)")
                                            
                                            Spacer()
                                            
                                            Button(match.rightName) {
                                                print("winner is \(match.leftName)")
                                            }
                                        }
                                        .foregroundStyle(.primary)
                                        .buttonBorderShape(.roundedRectangle)
                                        .buttonStyle(.bordered)
                                    }
                                    .padding(.horizontal, 20)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
                
                Tab("Standings", systemImage: "tablecells") {
                    // TODO: Replace me later
                    Text("Standings")
                }
                
                Tab("Charts", systemImage: "chart.pie") {
                    // TODO: Replace me later
                    Text("Charts")
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
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

extension Match {
    var leftName: String { left?.name ?? "Bye" }
    var rightName: String { right?.name ?? "Bye" }
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
