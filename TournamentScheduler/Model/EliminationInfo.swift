import SwiftData

@Model
final class EliminationInfo {
    var isLoserBracket: Bool
    var prevLeftMatch: Match?
    var prevRightMatch: Match?
    var firstLoserIndex = Int.max
    
    init(isLoserBracket: Bool = false,
         prevLeftMatch: Match? = nil,
         prevRightMatch: Match? = nil,
         firstLoserIndex: Int = Int.max) {
        self.isLoserBracket = isLoserBracket
        self.prevLeftMatch = prevLeftMatch
        self.prevRightMatch = prevRightMatch
        self.firstLoserIndex = firstLoserIndex
    }
}
