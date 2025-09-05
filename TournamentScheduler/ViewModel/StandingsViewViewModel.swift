import Foundation

struct RankInfo: Identifiable {
    let id: UUID = .init()
    var oldrank : Int
    var rank : Int
    var name : String
    var countParticipated: Int
    var countPlayed : Int
    var countWins : Int
    var countLost : Int
    var countDrawn : Int
    var pointsFor : Int
    var pointsAgainst : Int
    var pointsDifference : Int
}
    
struct StandingsViewViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    let nOverP: Int
    
    init(pool: Pool) {
        ranks = Self.calculateRanks(pool, isForCharts: false)
        schedule = pool.schedule
        nOverP = ranks.first?.countParticipated ?? 0
    }
}
