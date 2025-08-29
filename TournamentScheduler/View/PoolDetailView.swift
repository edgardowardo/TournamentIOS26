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
                ForEach(filteredRounds) { round in
                    
                    
                    
                    Text("Round \(round.value)")
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
//            List {
//                Text("Matches")
//                
//                Text("\(item.name) has \(item.participants.count) parties, \(item.matchCount) matches, \(item.rounds.count) rounds\(item.isHandicap ? " (handicapped)" : "")")
//            }
            .navigationTitle(item.name)
            .navigationSubtitle(Text("\(item.rounds.count) rounds, \(item.matchCount) matches, \(item.participants.count) seeds"))
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
            tourType: .roundRobin,
            timestamp: .now,
            tournament: nil,
            participants: [])
        pool.rounds = [.init(value: 1, matches: []), .init(value: 2, matches: []), .init(value: 3, matches: [])]
        context.insert(pool)
        return PoolDetailView(item: pool)
            .modelContainer(container)
    }()
    view
}

