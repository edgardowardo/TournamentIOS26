import Combine

class FormPoolViewModel: ObservableObject {
    struct SeedViewModel: Identifiable {
        let id: Int
        var name: String
        var value: String
    }
    
    @Published var seedsViewModels: [SeedViewModel]
    @Published var seedCount: Int
    let seedType: InitialSeedNames = .footballers
        
    init(item: Pool?) {
        let initialSeedCount = item?.seedCount ?? 4
        self.seedCount = initialSeedCount
        
        if let seeds = item?.participants {
            self.seedsViewModels = seeds.map { s in
                .init(id: s.seed, name: s.name, value: "\(s.seed)")
            }.sorted { $0.id < $1.id }
        } else {
            seedsViewModels = seedType.pickRandomNames(initialSeedCount).enumerated().map { index, name in
                .init(id: index + 1, name: name, value: "")
            }
        }
    }
            
    func updatedSeedCount(from oldValue: Int, to newValue: Int) {
        guard oldValue != newValue else { return }
        seedsViewModels = seedType.pickRandomNames(newValue).enumerated().map { index, name in
            .init(id: index + 1, name: name, value: "")
        }
    }
}
