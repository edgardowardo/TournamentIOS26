import Foundation
import Combine

extension FormPoolView {
    class ViewModel: ObservableObject {
        class SeedViewModel: Identifiable, Equatable {
            let id = UUID()
            var seed: Int
            var name: String
            var handicapPoints: String
            
            static func == (lhs: SeedViewModel, rhs: SeedViewModel) -> Bool {
                lhs.id == rhs.id
            }
            
            init(seed: Int, name: String, handicapPoints: String) {
                self.seed = seed
                self.name = name
                self.handicapPoints = handicapPoints
            }
        }
        
        @Published var seedsViewModels: [SeedViewModel]
        @Published var seedCount: Int
        @Published var scheduleType: Schedule = .roundRobin
        private let resetViewModels: [SeedViewModel]
        private let seedNames: SeedNames = {
            if let raw = UserDefaults.standard.string(forKey: SeedNames.userDefaultsKey), let value = SeedNames(rawValue: raw) {
                return value
            }
            return .mixed
        }()
        
        init(item: Pool?) {
            let initialSeedCount = item?.seedCount ?? 4
            seedCount = initialSeedCount
            let models: [SeedViewModel]
            if let seeds = item?.participants {
                models = seeds.map { s in
                        .init(seed: s.seed, name: s.name, handicapPoints: "\(s.handicapPoints)")
                }.sorted { $0.seed < $1.seed }
            } else {
                models = seedNames.pickRandomNames(initialSeedCount).enumerated().map { index, name in
                        .init(seed: index + 1, name: name, handicapPoints: "")
                }
            }
            resetViewModels = models
            seedsViewModels = models
        }
        
        func updatedSeedCount(from oldValue: Int, to newValue: Int) {
            guard oldValue != newValue else { return }
            seedsViewModels = seedNames.pickRandomNames(newValue).enumerated().map { index, name in
                    .init(seed: index + 1, name: name, handicapPoints: "")
            }
        }
        
        func shuffle() {
            seedsViewModels.shuffle()
            setSeedNumbers()
        }
        
        func reset() {
            seedsViewModels = resetViewModels
            seedCount = seedsViewModels.count
            setSeedNumbers()
        }
        
        private func setSeedNumbers() {
            var seed = 1
            for s in seedsViewModels {
                s.seed = seed
                seed += 1
            }
        }
        
        func overrideSeeds(_ pool: Pool) {
            seedsViewModels = pool.participants.map { s in
                    .init(seed: s.seed, name: s.name, handicapPoints: "\(s.handicapPoints)")
            }.sorted { $0.seed < $1.seed }
            
            

            // TODO: pool is not the source of truth of schedule
            if !pool.schedule.allowedSeedCounts.contains(seedsViewModels.count) {
//                pool.schedule.allowedSeedCounts.filter
            }
            
            seedCount = seedsViewModels.count
        }
    }
}

