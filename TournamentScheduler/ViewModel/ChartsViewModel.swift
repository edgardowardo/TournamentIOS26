struct ChartsViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    var nOverP: Int { 0 }
    let countMatches: Int
    let countMatchWins: Int
    let countMatchDraws: Int
    
    init(pool: Pool) {
        var p = pool
        ranks = Self.calculateRanks(&p)
        schedule = p.schedule
        countMatches = p.countMatches
        countMatchWins = p.countMatchWins
        countMatchDraws = p.countMatchDraws
    }
}
