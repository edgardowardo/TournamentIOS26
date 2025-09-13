struct RoundRobinScheduler: ScheduleProviding {
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
        guard round < elements.count else {
            return
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
        
        // shift the elements to process as the next row. the first element is fixed hence insert to position one.
        var nextrow = elements
        let displaced = nextrow.removeLast()
        nextrow.insert(displaced, at: 1)
        
        generate(round + 1, index, nextrow)
    }
    
}

extension Match {
    func calculateHandicapScores() {
        guard let left, let right else {
            return
        }
        let leftHandicap = left.handicapPoints + (doublesInfo?.leftParticipant2?.handicapPoints ?? 0)
        let rightHandicap = right.handicapPoints + (doublesInfo?.rightParticipant2?.handicapPoints ?? 0)
        let difference = abs(leftHandicap - rightHandicap)
        if leftHandicap > rightHandicap {
            leftScore = difference / 2
            rightScore = -(difference / 2)
        } else if leftHandicap < rightHandicap {
            leftScore = -(difference / 2)
            rightScore = difference / 2
        }
    }
}

