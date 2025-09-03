import Foundation

struct StandingsRowViewModel {
    var oldrank : Int
    var rank : Int
    var name : String
    var countPlayed : Int
    var countWins : Int
    var countLost : Int
    var countDrawn : Int
    var pointsFor : Int
    var pointsAgainst : Int
    var pointsDifference : Int
}

struct StandingsViewModel {
    let standings: [StandingsRowViewModel]
    
    init(pool: Pool) {
        var ranksMap = [Participant: StandingsRowViewModel](
            uniqueKeysWithValues:
                pool.participants.map {
                    ($0, StandingsRowViewModel(
                        oldrank: $0.seed,
                        rank: 0,
                        name: $0.name,
                        countPlayed: 0,
                        countWins: 0,
                        countLost: 0,
                        countDrawn: 0,
                        pointsFor: 0,
                        pointsAgainst: 0,
                        pointsDifference: 0)
                    )
                }
        )
        
        for r in pool.rounds {
            for m in r.matches {
                if let left = m.left, var stats = ranksMap[left] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    stats.pointsFor += m.leftScore
                    stats.pointsAgainst += m.rightScore
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    if left == m.winner {
                        stats.countWins += 1
                    } else if left == m.loser {
                        stats.countLost += 1
                    }
                    ranksMap[left] = stats
                }
                if let left2 = m.left2, var stats = ranksMap[left2] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    stats.pointsFor += m.leftScore
                    stats.pointsAgainst += m.rightScore
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    if left2 == m.winner2 {
                        stats.countWins += 1
                    } else if left2 == m.loser2 {
                        stats.countLost += 1
                    }
                    ranksMap[left2] = stats
                }
                if let right = m.right, var stats = ranksMap[right] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    stats.pointsFor += m.rightScore
                    stats.pointsAgainst += m.leftScore
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    if right == m.winner {
                        stats.countWins += 1
                    } else if right == m.loser {
                        stats.countLost += 1
                    }
                    ranksMap[right] = stats
                }
                if let right2 = m.right2, var stats = ranksMap[right2] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    stats.pointsFor += m.rightScore
                    stats.pointsAgainst += m.leftScore
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    if right2 == m.winner2 {
                        stats.countWins += 1
                    } else if right2 == m.loser2 {
                        stats.countLost += 1
                    }
                    ranksMap[right2] = stats
                }
            }
        }
                
        var unranked = ranksMap.values.compactMap { $0 }.sorted { a, b in
            if a.countWins != b.countWins {
                return a.countWins > b.countWins
            } else if a.countDrawn != b.countDrawn {
                return a.countDrawn > b.countDrawn
            } else {
                return a.pointsDifference > b.pointsDifference
            }
        }
        for i in unranked.indices {
            unranked[i].rank = i + 1
        }
        standings = unranked
    }
}

fileprivate extension Match {
    
    var left2: Participant? { doublesInfo?.leftParticipant2 }
    var right2: Participant? { doublesInfo?.rightParticipant2 }
    
    var winner2: Participant? {
        if let winner {
            if winner == left {
                return left2
            } else if winner == right {
                return right2
            }
        }
        return nil
    }
    
    var loser: Participant? {
        if let winner {
            if winner == left {
                return right
            } else if winner == right {
                return left
            }
        }
        return nil
    }
    
    var loser2: Participant? {
        if let winner2 {
            if winner2 == left2 {
                return right2
            } else if winner2 == right2 {
                return left2
            }
        }
        return nil
    }
}
