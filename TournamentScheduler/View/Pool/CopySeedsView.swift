import SwiftUI
import SwiftData

struct CopySeedsView: View {
    
    var onSave: (_ pool: Pool) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Pool> { pool in pool.isSeedsCopyable },
           sort: \Pool.timestamp, order: .reverse) private var items: [Pool]
    
    var body: some View {
        NavigationStack {
            List(items) { pool in
                let vm = RanksViewModel(pool: pool)
                NavigationLink(
                    destination: RanksView(vm: vm, isShowAllStats: false) { EmptyView() }
                        .padding(.horizontal)
                        .navigationTitle(Text("Copy Seeds"))
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Save", systemImage: "checkmark") {
                                    dismiss()
                                    onSave(pool)
                                }
                                .tint(.blue)
                            }
                        }
                ) {
                    HStack {
                        Text(pool.name)
                        
                        Spacer()
                        
                        Text(pool.participants.count.formatted())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: pool.schedule.sfSymbolName)
                        
                        if let sportSymbolName = pool.tournament?.sport.sfSymbolName {
                            Image(systemName: sportSymbolName)
                        }
                    }
                }
            }
            .navigationTitle(Text("Copy Seeds"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
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
            tournament: .init(),
            participants: [])
        context.insert(pool)
        return CopySeedsView() { _ in }
            .modelContainer(container)
    }()
    view
}
