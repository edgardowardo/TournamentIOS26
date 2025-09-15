
struct DoubleEliminationScheduler: ScheduleProviding, SingleEliminationProviding {
    
    var pool: Pool
    
    func schedule() {
        var elements: [Participant?] = pool.participants
        
        // If two teams, make it 4 beacause it needs 4 to make the losers bracket
        if elements.count == 2 {
            elements.append(contentsOf: Array(repeating: nil, count: 2))
        }

        // Build single elimination tree aka winners bracket
        generateFirstRound(1, pool.participants)
        
        guard let lastWinnersGame = pool.rounds.last?.matches.last, let firstRound = pool.rounds.first else { return }
                
        // Build losers bracket
        pool.firstLoserIndex = lastWinnersGame.index + 1
        generateLosersRound(pool.firstLoserIndex, 2, 2, lastRound: firstRound)
        
        // Build the finals
        guard let lastLosersGame = pool.losers.last?.matches.last else { return }
        
        let m: Match = .init(
            index: lastLosersGame.index + 1,
            round: lastWinnersGame.round,
            winner: nil,
            left: nil,
            right: nil,
            isBye: false,
            prevLeftMatch: lastWinnersGame,
            prevRightMatch: lastLosersGame
        )
        m.isFinals = true
        let r: Round = .init(value: (lastWinnersGame.round?.value ?? 0) + 1,
                             pool: pool)
        r.matches.append(m)
        pool.rounds.append(r)
    }
    
    private func generateLosersRound(_ index: Int, _ round: Int, _ winnerRound: Int, lastRound: Round) {
        var index = index
        
        // base case
        guard lastRound.matches.count > 1 else { return }
        
        let r: Round = .init(value: round, losersPool: pool)
        pool.losers.append(r)
        
        // apply rainbow pairings for the matches of last round. losers are yet to be determined.
        // examine last round matches and create new ones for the next round
        var endIndex = lastRound.matches.count - 1
        
        for i in (0..<lastRound.matches.count/2).reversed() {
            let leftMatch = lastRound.matches[i]
            let rightMatch = lastRound.matches[endIndex - i]
            
            // Create the match
            let m: Match = .init(
                index: index,
                round: r,
                winner: nil,
                left: nil,
                right: nil,
                isBye: r.value == 2 && (leftMatch.isBye || rightMatch.isBye),
                prevLeftMatch: leftMatch,
                prevRightMatch: rightMatch
            )
            
            r.matches.append(m)
            index += 1
        }
        
        let mixedRound: Round = .init(value: round + 1, losersPool: pool)
        pool.losers.append(mixedRound)

        // the mixed round has the same number of matches as `r`.
        // this is a rainbow pairings for the ancitipated losers of the curent round and winners of `r` matches.
        let losersMatches = pool.rounds.first { $0.value == winnerRound }?.matches ?? []
        let mixedMatches = r.matches + losersMatches.reversed()
        endIndex = mixedMatches.count - 1
        for i in (0..<mixedMatches.count/2).reversed() {
            let leftMatch = mixedMatches[i]
            let rightMatch = mixedMatches[endIndex - i]
                        
            // Create the match
            let m: Match = .init(
                index: index,
                round: mixedRound,
                winner: nil,
                left: nil,
                right: nil,
                isBye: mixedRound.value == 3 && (leftMatch.isBothBye || rightMatch.isBothBye),
                prevLeftMatch: leftMatch,
                prevRightMatch: rightMatch
            )
            
            mixedRound.matches.append(m)
            index += 1
        }
        
        generateLosersRound(index, mixedRound.value + 1, winnerRound + 1, lastRound: mixedRound)
    }
}
