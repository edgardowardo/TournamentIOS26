import SwiftData

@Model
final class Match {
    var index = 0
    var winner: Participant? = nil
    var left: Participant? = nil
    var right: Participant? = nil
    var isBye: Bool = false
    var isDraw: Bool = false
    var leftScore = 0
    var rightScore = 0
    var round: Round?

    var prevLeftMatch: Match? = nil // for elimination schedules
    var prevRightMatch: Match? = nil

    @Relationship(deleteRule: .cascade) var doublesInfo: DoublesInfo? = nil
    
    init(index: Int,
         round: Round?,
         winner: Participant? = nil,
         left: Participant? = nil,
         right: Participant? = nil,
         isBye: Bool = false,
         isDraw: Bool = false,
         leftScore: Int = 0,
         rightScore: Int = 0,         
         prevLeftMatch: Match? = nil,
         prevRightMatch: Match? = nil,
         doublesInfo: DoublesInfo? = nil
    ) {
        self.index = index
        self.round = round
        self.winner = winner
        self.left = left
        self.right = right
        self.isBye = isBye
        self.isDraw = isDraw
        self.leftScore = leftScore
        self.rightScore = rightScore
        self.prevLeftMatch = prevLeftMatch
        self.prevRightMatch = prevRightMatch
        self.doublesInfo = doublesInfo
    }
}

extension Match: CustomStringConvertible {
    private var leftWinnerMarker: String { winner == left ? "(w)" : "" }
    private var rightWinnerMarker: String { winner == right ? "(w)" : "" }
    
    var description: String {
        "\(index): \(leftWinnerMarker)\(leftName) vs \(rightWinnerMarker)\(rightName). isBye: \(isBye)"
    }
}

extension Match {
    
    var leftName: String {
        if let left {
            if let doublesInfo, let leftParticipant2 = doublesInfo.leftParticipant2 {
                return "\(left.name) / \(leftParticipant2.name)"
            } else {
                return left.name
            }
        } else if isBye {
            return "BYE"
        } else {
            return " "
        }
    }
    
    var rightName: String {
        if let right {
            if let doublesInfo, let rightParticipant2 = doublesInfo.rightParticipant2 {
                return "\(right.name) / \(rightParticipant2.name)"
            } else {
                return right.name
            }
        } else if isBye {
            return "BYE"
        } else {
            return " "
        }
    }
    
    var loser: Participant? {
        if !isBye, let winner {
            if winner == left {
                return right
            } else if winner == right {
                return left
            }
        }
        return nil
    }
}
