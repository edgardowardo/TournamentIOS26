import Foundation

struct RankInfo: Identifiable {
    let id: UUID = .init()
    var oldrank : Int
    var rank : Int
    var name : String

    /// Used in Round Robin and American Doubles for N/P header showing how many games expecting to play excluding byes.
    var countParticipated: Int

    /// Played means Match has been played and finished where it's not a bye and is a draw or a winner announced
    var countPlayed : Int
    
    /// Actual wins excluding byes
    var countWins : Int
    var countLost : Int
    var countDrawn : Int
    var countBye: Int
    var pointsFor : Int
    var pointsAgainst : Int
    var pointsDifference : Int
}
    
struct RanksViewModel: StatisticsProviding {
    let ranks: [RankInfo]
    let schedule: Schedule
    let nOverP: Int
    let countMatches: Int
    let countMatchByes: Int
    let countMatchDraws: Int
    let countMatchWins: Int
    
    init(pool: Pool) {
        var p = pool
        ranks = Self.calculateRanks(&p)
        schedule = pool.schedule
        nOverP = ranks.first?.countParticipated ?? 0
        countMatches = p.countMatches
        countMatchByes = p.countMatchByes
        countMatchDraws = p.countMatchDraws
        countMatchWins = p.countMatchWins
    }
}
