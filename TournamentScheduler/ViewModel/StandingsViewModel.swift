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
                    if left == m.winner {
                        stats.countWins += 1
                        stats.pointsFor += m.leftScore
                    } else if left == m.loser {
                        stats.countLost += 1
                        stats.pointsAgainst += m.rightScore
                    }
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    ranksMap[left] = stats
                }
                if let left2 = m.left2, var stats = ranksMap[left2] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    if left2 == m.winner2 {
                        stats.countWins += 1
                        stats.pointsFor += m.leftScore
                    } else if left2 == m.loser2 {
                        stats.countLost += 1
                        stats.pointsAgainst += m.rightScore
                    }
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    ranksMap[left2] = stats
                }
                if let right = m.right, var stats = ranksMap[right] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    if right == m.winner {
                        stats.countWins += 1
                        stats.pointsFor += m.rightScore
                    } else if right == m.loser {
                        stats.countLost += 1
                        stats.pointsAgainst += m.leftScore
                    }
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    ranksMap[right] = stats
                }
                if let right2 = m.right2, var stats = ranksMap[right2] {
                    stats.countPlayed += 1
                    stats.countDrawn += (m.isDraw ? 1 : 0)
                    if right2 == m.winner2 {
                        stats.countWins += 1
                        stats.pointsFor += m.rightScore
                    } else if right2 == m.loser2 {
                        stats.countLost += 1
                        stats.pointsAgainst += m.leftScore
                    }
                    stats.pointsDifference = stats.pointsFor - stats.pointsAgainst
                    ranksMap[right2] = stats
                }
            }
        }
                
        var unranks = ranksMap.values.compactMap { $0 }.sorted { $0.rawSeedings > $1.rawSeedings }
        for i in unranks.indices {
            unranks[i].rank = i + 1
        }
        standings = unranks
    }
}

fileprivate let winFactor = 1_000.0, drawFactor = 100.0, differenceFactor = 0.1

fileprivate extension StandingsRowViewModel {
    var rawSeedings: Double {
        Double(countWins) * winFactor
        + Double(countDrawn) * drawFactor
        + Double(pointsDifference) * differenceFactor
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
