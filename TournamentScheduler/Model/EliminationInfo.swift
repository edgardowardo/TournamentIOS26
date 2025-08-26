import SwiftData

@Model
final class EliminationInfo {
    var isLoserBracket = false
    var leftMatchIndex = 0
    var prevLeftMatch: Match? = nil
    var rightMatchIndex = 0
    var prevRightMatch: Match? = nil
    var firstLoserIndex = Int.max
    
    init(isLoserBracket: Bool = false, leftMatchIndex: Int = 0, prevLeftMatch: Match? = nil, rightMatchIndex: Int = 0, prevRightMatch: Match? = nil, firstLoserIndex: Int = Int.max) {
        self.isLoserBracket = isLoserBracket
        self.leftMatchIndex = leftMatchIndex
        self.prevLeftMatch = prevLeftMatch
        self.rightMatchIndex = rightMatchIndex
        self.prevRightMatch = prevRightMatch
        self.firstLoserIndex = firstLoserIndex
    }
}
