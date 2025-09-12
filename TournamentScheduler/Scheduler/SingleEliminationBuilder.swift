
struct SingleEliminationScheduler: ScheduleProviding {
    
    var pool: Pool
    
    func schedule() {
        generateFirstRound(1, pool.participants)
    }
    
    private func generateFirstRound(_ round: Int, _ teams: [Participant?]) {
        var index = 1, elements = teams
        
        // Adjust the number of teams with a bye, necessary to construct the brackets which are 2, 4, 8, 16, 32 and 64
        for min in [2, 4, 8, 16, 32, 64] {
            if elements.count < min {
                let byeCount = min - elements.count
                elements.append(contentsOf: Array(repeating: nil, count: byeCount))
                break
            } else if elements.count == min {
                break
            }
        }
        
        let r: Round = .init(value: round, pool: pool)
        pool.rounds.append(r)
        
        // process half the elements to create the pairs
        let endIndex = elements.count - 1
        for i in (0..<elements.count/2).reversed() {
            let left = elements[i], right = elements[endIndex - i]
            let winner: Participant? = (left == nil) ? right : (right == nil) ? left : nil
            let isBye = (left == nil || right == nil)

            // Create the match
            let m: Match = .init(
                index: index,
                round: r,
                winner: winner,
                left: left,
                right: right,
                isBye: isBye
            )
            m.calculateHandicapScores()
            r.matches.append(m)
            index += 1
        }
        
        
        // apply rainbow pairing for the new game winners instead of teams
        generateFutureRounds(index, round + 1, r)
    }
    
    private func generateFutureRounds(_ index: Int, _ round: Int, _ lastRound: Round) {
        var index = index
        
        // base case
        guard lastRound.matches.count > 1 else { return }
                
        let r: Round = .init(value: round, pool: pool)
        pool.rounds.append(r)

        // examine last round matches and create new ones for the next round
        let endIndex = lastRound.matches.count - 1
        for i in (0..<lastRound.matches.count/2).reversed() {
            let leftMatch = lastRound.matches[i]
            let rightMatch = lastRound.matches[endIndex - i]
            
            // Create the match
            let m: Match = .init(
                index: index,
                round: r,
                winner: nil,
                left: leftMatch.winner,
                right: rightMatch.winner,
                isBye: false,
                eliminationInfo: .init(
                    isLoserBracket: false,
                    prevLeftMatch: leftMatch,
                    prevRightMatch: rightMatch
                )
            )
            r.matches.append(m)
            index += 1
        }
        
        generateFutureRounds(index, round + 1, r)
    }
}
