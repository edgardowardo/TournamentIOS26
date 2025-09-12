struct AmericanDoublesScheduler: ScheduleProviding {
    
    var pool: Pool
    
    func schedule() {
        generate(1, 1, pool.participants)
    }
    
    private func generate(_ round: Int, _ startIndex: Int, _ row: [Participant?]) {
        var index = startIndex, elements = row
                
        // if odd then add a bye
        if !elements.count.isMultiple(of: 2) {
            elements.append(nil)
        }

        // base case
        var topHalf = (elements.count / 2) - 1
        guard round < elements.count && row.count > 3 else {
            return
        }
        
        let r: Round = .init(value: round, pool: pool)
        pool.rounds.append(r)
        
        // process half the elements to create the pairs
        let endIndex = elements.count - 1
        
        while topHalf > 0 {
            let i = topHalf
                        
            guard   // left pair
                    let l1 = elements[i],
                    let l2 = elements[i - 1],
                    // right pair
                    let r1 = elements[endIndex - i],
                    let r2 = elements[endIndex - (i - 1)] else {
                break
            }
            
            // Create the match
            let m: Match = .init(
                index: index,
                round: r,
                winner: nil,
                left: l1,
                right: r1,
                isBye: false,
                doublesInfo: .init(leftParticipant2: l2, rightParticipant2: r2)
            )
            m.calculateHandicapScores()
            r.matches.append(m)
            
            index += 1
            topHalf -= 2
        }
                
        // shift the elements to process as the next row. the last element is fixed hence, displaced is minus two.
        let displaced = elements.remove(at: elements.count - 2)
        elements.insert(displaced, at: 0)
        
        generate(round + 1, index, elements)
    }
}
