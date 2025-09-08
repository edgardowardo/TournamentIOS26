import Foundation
    
struct RanksViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    let nOverP: Int
    let poolName: String
    let countMatches: Int
    let countMatchByes: Int
    let countMatchDraws: Int
    let countMatchWins: Int
    
    init(pool: Pool) {
        var p = pool
        ranks = Self.calculateRanks(&p)
        schedule = pool.schedule
        nOverP = ranks.first?.countParticipated ?? 0
        poolName = p.name
        countMatches = p.countMatches
        countMatchByes = p.countMatchByes
        countMatchDraws = p.countMatchDraws
        countMatchWins = p.countMatchWins
    }
}
