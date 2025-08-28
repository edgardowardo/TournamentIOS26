import SwiftUI
import SwiftData

struct PoolDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    
    private let sourceIDEditPool = "PoolEdit"
    
    let item: Pool
    
    var body: some View {
        NavigationStack {
            List {
                Text("Rounds")
                Text("\(item.name) has \(item.participants.count) parties, \(item.matches.count) matches, \(item.rounds) rounds\(item.isHandicap ? " (handicapped)" : "")")
            }
            .navigationTitle(item.name)
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
                    .navigationTransition(.zoom(sourceID: sourceIDEditPool, in: animationNamespace))
            }
        }
    }
}


