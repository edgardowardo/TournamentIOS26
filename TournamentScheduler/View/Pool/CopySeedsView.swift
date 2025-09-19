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
                            }
                        }
                ) {
                    Text(pool.name)
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
    CopySeedsView() { _ in }
}
