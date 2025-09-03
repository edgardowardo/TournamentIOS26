import Combine

final class RoundViewModel: ObservableObject, Identifiable {
    @Published var item: Round
    @Published var matchVMs: [MatchViewModel]
    
    init(item: Round) {
        self.item = item
        self.matchVMs = item.matches
            .sorted { $0.index < $1.index }
            .map { .init(match: $0) }
    }
}

final class RoundsViewModel: ObservableObject {
    @Published var roundVMs: [RoundViewModel]
    
    init(pool: Pool, filterRound: Int) {
        roundVMs = pool.rounds
            .filter { filterRound == -1 || $0.value == filterRound }
            .sorted { $0.value < $1.value }
            .map { .init(item: $0) }
    }
}
