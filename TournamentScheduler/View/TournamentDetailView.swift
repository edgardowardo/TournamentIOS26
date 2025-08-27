import SwiftUI
import SwiftData

struct TournamentDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Namespace private var animation
    @State private var showEditTournament: Bool = false
    @State private var showAddPool: Bool = false
    
    private let sourceIDEditTournament = "TournamentEdit"
    private let sourceIDAddPool = "TournamentAddPool"

    let item: Tournament
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    HStack {
                        Image(systemName:item.sport.sfSymbolName)
                            .resizable()
                            .frame(width: 75, height: 75)
                            .padding()
                        VStack(alignment: .leading) {
                            Text("\(item.pools.count.spelledOut?.capitalized ?? "no") pools")
                            Text(item.tags)
                        }
                    }
                }
                
                Section(
                    header: Text("Pools"),
                    footer: Text("You can add pools of matches using the + button. Swipe left to delete. A pool can be scheduled with round-robin, american, single and double elimination.")
                ) {
                    ForEach(item.pools) { pool in
                        NavigationLink {
                            // TODO: Replace me
                            Text(pool.name)
                        } label: {
                            HStack(spacing: 20) {
                                Image(systemName:pool.tourType.sfSymbolName)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading) {
                                    Text(pool.name)
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                    Text("\(pool.participants.count) parties, \(pool.matches.count) matches, \(pool.rounds) rounds\(pool.isHandicap ? " (handicapped)" : "")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
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
                    .navigationTransition(.zoom(sourceID: sourceIDAddPool, in: animation))
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(item.pools[index])
            }
        }
    }
}

extension Pool {
    var rounds: Int { Set(self.matches.map(\.round)).count }
}

#Preview {
    TournamentDetailView(item: Tournament(name: "Spring Open", sport: .tennis, timestamp: Date(), pools: []))
}
