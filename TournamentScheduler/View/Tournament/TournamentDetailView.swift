import SwiftUI
import SwiftData

struct TournamentDetailView: View {

    @Bindable var item: Tournament

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pool.timestamp, order: .reverse) private var pools: [Pool]
    @Namespace private var animation
    @State private var isAnimateSymbol = false
    @State private var showEditTournament: Bool = false
    @State private var showAddPool: Bool = false
    private let sourceIDEditTournament = "TournamentEdit"
    private let sourceIDAddPool = "TournamentAddPool"
        
    var body: some View {
        let filteredPools = pools.filter { $0.tournament == item }
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    HStack {
                        Image(systemName:item.sport.sfSymbolName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 75)
                            .padding()
                            .symbolEffect(.bounce.down, value: isAnimateSymbol)
                        VStack(alignment: .leading) {
                            Text("\(filteredPools.count.spelledOut?.capitalized ?? "no") pools")
                            Text(item.tags)
                        }
                    }
                }
                
                Section(
                    header: Text("Pools"),
                    footer: Text("Add pools of matches using the + button. Swipe left to delete. A pool can be scheduled with round-robin, american, single and double elimination.")
                ) {
                    ForEach(filteredPools) { pool in
                        NavigationLink {
                            PoolDetailView(item: pool)
                        } label: {
                            HStack(spacing: 20) {
                                Image(systemName:pool.schedule.sfSymbolName)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading) {
                                    Text(pool.name)
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                    Text("\(pool.rounds.count) rounds, \(pool.matchCount) matches, \(pool.participants.count) seeds\(pool.isHandicap ? " (handicapped)" : "")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isAnimateSymbol = true
                }
            }
            .onDisappear {
                isAnimateSymbol = false
            }
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit", systemImage: "square.and.pencil") {
                        showEditTournament.toggle()
                    }
                }
                .matchedTransitionSource(id: sourceIDEditTournament, in: animation)
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New", systemImage: "plus") {
                        showAddPool.toggle()
                    }
                }
                .matchedTransitionSource(id: sourceIDAddPool, in: animation)
            }
            .sheet(isPresented: $showEditTournament) {
                FormTournamentView(tournament: item, onDismiss: { showEditTournament = false })
                    .navigationTransition(.zoom(sourceID: sourceIDEditTournament, in: animation))
            }
            .sheet(isPresented: $showAddPool) {
                FormPoolView(parent: item, onDismiss: { showAddPool = false })
                    .interactiveDismissDisabled(true)
                    .navigationTransition(.zoom(sourceID: sourceIDAddPool, in: animation))
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        let filteredPools = pools.filter { $0.tournament == item }
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredPools[index])
            }
            item.timestamp = .now
            Task { @MainActor in
                try modelContext.save()
            }
        }
    }
}

#Preview {
    TournamentDetailView(item: Tournament(name: "Spring Open", sport: .tennis, timestamp: Date(), pools: []))
}
