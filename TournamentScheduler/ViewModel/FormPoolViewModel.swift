import Foundation
import Combine

class FormPoolViewModel: ObservableObject {
    struct SeedViewModel: Identifiable {
        let id = UUID()
        let seed: Int
        var name: String
        var handicapPoints: String
    }
    
    @Published var seedsViewModels: [SeedViewModel]
    @Published var seedCount: Int
    let seedType: InitialSeedNames = .footballers
        
    init(item: Pool?) {
        let initialSeedCount = item?.seedCount ?? 4
        self.seedCount = initialSeedCount
        
        if let seeds = item?.participants {
            self.seedsViewModels = seeds.map { s in
                    .init(seed: s.seed, name: s.name, handicapPoints: "\(s.handicapPoints)")
            }.sorted { $0.seed < $1.seed }
        } else {
            seedsViewModels = seedType.pickRandomNames(initialSeedCount).enumerated().map { index, name in
                .init(seed: index + 1, name: name, handicapPoints: "")
            }
        }
    }
            
    func updatedSeedCount(from oldValue: Int, to newValue: Int) {
        guard oldValue != newValue else { return }
        seedsViewModels = seedType.pickRandomNames(newValue).enumerated().map { index, name in
            .init(seed: index + 1, name: name, handicapPoints: "")
        }
    }
}
