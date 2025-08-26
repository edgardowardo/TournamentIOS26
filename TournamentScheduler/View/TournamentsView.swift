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
                    footer: Text("You can add tournaments using the + button. Each tournament can be renamed or deleted and may contain several groups of scheduled matches.")
                ) {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            Text(item.name)
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
    TournamentsView()
        .modelContainer(for: Tournament.self, inMemory: true)
}
