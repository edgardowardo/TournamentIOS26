struct ChartsViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    var nOverP: Int { 0 }
    
    init(pool: Pool) {
        ranks = Self.calculateRanks(pool, isForCharts: true)
        schedule = pool.schedule
    }
}
