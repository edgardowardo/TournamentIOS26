import SwiftUI
import SwiftData

struct TournamentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tournament.timestamp, order: .reverse) private var items: [Tournament]
    @Namespace private var animation
    @State private var showAddTournament: Bool = false
    
    private let sourceIDAddTournament = "Tournament"

    var body: some View {
        NavigationSplitView {
            Form {
                Section(
                    header: Text("Latest"),
                    footer: Text("You can add tournaments using the + button. Each tournament can be renamed or deleted and may contain several pool of scheduled matches.")
                ) {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            HStack {
                                Image(systemName:item.sport.sfSymbolName)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(item.name)
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(item.pools.count)")
                                    .font(.default)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Tournament")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem {
                    Button("New", systemImage: "plus") {
                        showAddTournament.toggle()
                    }
                }
                .matchedTransitionSource(id: sourceIDAddTournament, in: animation)
            }
            .sheet(isPresented: $showAddTournament) {
                FormTournamentView(onDismiss: { showAddTournament = false })
                    .navigationTransition(.zoom(sourceID: sourceIDAddTournament, in: animation))
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}


#Preview {
    let view: some View = {
        let container = try! ModelContainer(for: Tournament.self)
        let context = container.mainContext
        
        let fetchDescriptor = FetchDescriptor<Tournament>()
        let allTournaments = (try? context.fetch(fetchDescriptor)) ?? []
        for tournament in allTournaments { context.delete(tournament) }

        // Create sample data
        let t1 = Tournament(name: "Spring Open", sport: .tennis, timestamp: Date(), pools: [])
        let t2 = Tournament(name: "Summer Cup", sport: .soccer, timestamp: Date().addingTimeInterval(-86400), pools: [])
        context.insert(t1)
        context.insert(t2)
        
        return TournamentsView()
            .modelContainer(container)
    }()
    view
}
