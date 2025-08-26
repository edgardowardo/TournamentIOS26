import SwiftUI
import SwiftData

struct TournamentDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Namespace private var animation
    @State private var showEditTournament: Bool = false
    
    private let sourceIDEditTournament = "TournamentEdit"

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
            }
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit", systemImage: "square.and.pencil") {
                        showEditTournament.toggle()
                    }
                }
                .matchedTransitionSource(id: sourceIDEditTournament, in: animation)
            }
            .sheet(isPresented: $showEditTournament) {
                FormTournamentView(tournament: item, onDismiss: { showEditTournament = false })
                    .navigationTransition(.zoom(sourceID: sourceIDEditTournament, in: animation))
            }
        }
    }
}

#Preview {
    TournamentDetailView(item: Tournament(name: "Spring Open", sport: .tennis, timestamp: Date(), pools: []))
}
