struct ChartsViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    var nOverP: Int { 0 }
    let poolName: String
    let countMatches: Int
    let countMatchByes: Int
    let countMatchDraws: Int
    let countMatchWins: Int
    
    init(pool: Pool) {
        var p = pool
        ranks = Self.calculateRanks(&p)
        schedule = p.schedule
        self.poolName = p.name
        countMatches = p.countMatches
        countMatchByes = p.countMatchByes
        countMatchDraws = p.countMatchDraws
        countMatchWins = p.countMatchWins
    }
}
