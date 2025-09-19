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
        @Published var isForceSeedChange = false
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
            if let item {
                let seeds = item.participants
                scheduleType = item.schedule
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
            guard oldValue != newValue && !isForceSeedChange else {
                isForceSeedChange = false
                return
            }
            
            if newValue < oldValue {
                seedsViewModels.removeLast(oldValue - newValue)
            } else if newValue > oldValue {
                let namesToAdd: [SeedViewModel] = seedNames.pickRandomNames(newValue - oldValue).enumerated().map { index, name in
                        .init(seed: oldValue + index + 1, name: name, handicapPoints: "")
                }
                seedsViewModels.append(contentsOf: namesToAdd)
            }
        }
        
        func shuffle() {
            seedsViewModels.shuffle()
            setSeeds()
        }
        
        func reset() {
            seedsViewModels = resetViewModels
            isForceSeedChange = true
            seedCount = seedsViewModels.count
            setSeeds()
        }
        
        func setSeeds() {
            var seed = 1
            for s in seedsViewModels {
                s.seed = seed
                seed += 1
            }
        }
        
        func addSeeds(from pool: Pool) {
            let new: [SeedViewModel] = pool.participants.map { s in
                    .init(seed: s.seed, name: s.name, handicapPoints: "\(s.handicapPoints)")
            }.sorted { $0.seed < $1.seed }
            
            seedsViewModels.append(contentsOf: new)
         
            truncateSeedsIfNeeded()
        }
        
        func overrideSeeds(from pool: Pool) {
            guard scheduleType.minimumSeedCount <= pool.participants.count else { return }
            
            seedsViewModels = pool.participants.map { s in
                    .init(seed: s.seed, name: s.name, handicapPoints: "\(s.handicapPoints)")
            }.sorted { $0.seed < $1.seed }
            
            truncateSeedsIfNeeded()
        }
        
        func truncateSeedsIfNeeded() {
            // truncate seeds if count is not allowed
            let count = seedsViewModels.count, allowedSeedsCount = scheduleType.allowedSeedCounts
            if !allowedSeedsCount.contains(count),
                let allowedCount = allowedSeedsCount.filter({ $0 <= count }).last {
             
                seedsViewModels = Array(seedsViewModels.prefix(allowedCount))
            }
            setSeeds()
            isForceSeedChange = true
            seedCount = seedsViewModels.count
        }
    }
}

