
protocol StatisticsProviding {
    var ranks: [RankInfo] { get }
    var schedule: Schedule { get }
    var nOverP: Int { get }
    var countMatchWins: Int { get }
    var countMatchDraws: Int { get }
    var countMatches: Int { get }
}

extension StatisticsProviding {
    
    var countFinishedMatches: Int { countMatchWins + countMatchDraws + 0 /*countMatchByes*/ }
    
    static func calculateRanks(_ pool: inout Pool) -> [RankInfo] {
        var ranksMap = [Participant: RankInfo](
            uniqueKeysWithValues:
                pool.participants.map {
                    ($0, RankInfo(
                        oldrank: $0.seed,
                        rank: 0,
                        name: $0.name,
                        countParticipated: 0,
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
        
        var totalWins = 0, totalDraws = 0, totalMatches = 0
        
        for r in pool.rounds {
            for m in r.matches {
                totalMatches += 1
                totalDraws += m.isDraw ? 1 : 0
                totalWins += m.winner != nil ? 1 : 0
                
                if let left = m.left, var stats = ranksMap[left] {
                    stats.update(m, left, .left)
                    ranksMap[left] = stats
                }
                if let left2 = m.left2, var stats = ranksMap[left2] {
                    stats.update(m, left2, .left)
                    ranksMap[left2] = stats
                }
                if let right = m.right, var stats = ranksMap[right] {
                    stats.update(m, right, .right)
                    ranksMap[right] = stats
                }
                if let right2 = m.right2, var stats = ranksMap[right2] {
                    stats.update(m, right2, .right)
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
        // assign rankings
        for i in unranked.indices {
            unranked[i].rank = i + 1
        }
        pool.countMatchWins = totalWins
        pool.countMatchDraws = totalDraws
        pool.countMatches = totalMatches
        return unranked
    }
}

fileprivate extension RankInfo {
    mutating func update(_ m: Match, _ p: Participant, _ side: ScoreSide) {
        countParticipated += m.countParticipation(for: p)
        countPlayed += (m.isDraw || m.winner != nil ? 1 : 0)
        countDrawn += (m.isDraw ? 1 : 0)
        pointsFor += (side == .left ? m.leftScore : m.rightScore)
        pointsAgainst += (side == .left ? m.rightScore : m.leftScore)
        pointsDifference = pointsFor - pointsAgainst
        if p == m.winner || p == m.winner2 {
            countWins += 1
        } else if p == m.loser || p == m.loser2 {
            countLost += 1
        }
    }
}

fileprivate extension Match {

    func countParticipation(for p: Participant) -> Int {
        left == p || left2 == p || right == p || right2 == p ? 1 : 0
    }
    
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
