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
    
struct RanksViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    let nOverP: Int
    let countMatches: Int
    let countMatchWins: Int
    let countMatchDraws: Int
    
    init(pool: Pool) {
        var p = pool
        ranks = Self.calculateRanks(&p)
        schedule = pool.schedule
        nOverP = ranks.first?.countParticipated ?? 0
        countMatches = p.countMatches
        countMatchWins = p.countMatchWins
        countMatchDraws = p.countMatchDraws
    }
}
