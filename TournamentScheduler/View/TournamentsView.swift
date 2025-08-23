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
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Tournament")
            .toolbar {
                ToolbarItem {
                    Button("Add", systemImage: "plus") {
                        showAddTournament.toggle()
                    }
                }
                .matchedTransitionSource(id: sourceIDAddTournament, in: animation)
            }
            .sheet(isPresented: $showAddTournament) {
                Text("New Tournament")
                    .navigationTransition(.zoom(sourceID: sourceIDAddTournament, in: animation))
            }
        } detail: {
            Text("Select an item")
        }
    }
/*
    private func addItem() {
        withAnimation {
            let newItem = Tournament(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
*/
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
