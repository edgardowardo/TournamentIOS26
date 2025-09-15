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
    var isFinals: Bool = false

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
        "\(index): \(leftWinnerMarker)\(leftName) vs \(rightWinnerMarker)\(rightName). isBye: \(isBye), Winner: \(String(describing: winner))"
    }
}

extension Match {
    
    /// A match can belong to either normal pool or losersPool for double elimination schedule. They are mutually exclusive
    var pool: Pool? {
        round?.pool ?? round?.losersPool
    }
    
    /// A match belongs to the winners bracket
    var isWinnersBracket: Bool {
        self.round?.pool != nil
    }
    
    var isBothBye: Bool {
        leftName == "BYE" && rightName == "BYE"
    }
        
    var isLeftAndRightAssigned: Bool {
        left != nil && right != nil
    }

    var leftName: String {
        if let left {
            if let doublesInfo, let leftParticipant2 = doublesInfo.leftParticipant2 {
                return "\(left.name) / \(leftParticipant2.name)"
            } else {
                return left.name
            }
        } else if isBye && left == nil && right != nil {
            return "BYE"
        } else if isBye && (left == nil && right == nil && !isWinnersBracket),
                  let plm = prevLeftMatch, let prm = prevRightMatch,
                  plm.isBye && prm.isBye || plm.isBye && prm.isLeftAndRightAssigned {
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
        } else if isBye && right == nil && left != nil {                       // at least one player is assigned: left is waiting, right is nil
            return "BYE"
        } else if isBye && (left == nil && right == nil && !isWinnersBracket), // left and right are nil. losers bracket
                  let plm = prevLeftMatch, let prm = prevRightMatch,
                  // both previous left and right are bye
                  // previous left has its both sides assigned. and previous right is bye
                  plm.isBye && prm.isBye || plm.isLeftAndRightAssigned && prm.isBye {
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
