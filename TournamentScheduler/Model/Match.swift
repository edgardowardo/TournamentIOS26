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

    @Relationship(deleteRule: .cascade) var doublesInfo: DoublesInfo? = nil
    @Relationship(deleteRule: .cascade) var eliminationInfo: EliminationInfo? = nil
    
    init(index: Int = 0,
         winner: Participant? = nil,
         left: Participant? = nil,
         right: Participant? = nil,
         isBye: Bool,
         isDraw: Bool,
         leftScore: Int = 0,
         rightScore: Int = 0,
         doublesInfo: DoublesInfo? = nil,
         eliminationInfo: EliminationInfo? = nil
    ) {
        self.index = index
        self.winner = winner
        self.left = left
        self.right = right
        self.isBye = isBye
        self.isDraw = isDraw
        self.leftScore = leftScore
        self.rightScore = rightScore
        self.doublesInfo = doublesInfo
        self.eliminationInfo = eliminationInfo
    }
}
