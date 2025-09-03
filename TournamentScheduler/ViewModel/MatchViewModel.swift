import Combine

final class MatchViewModel: ObservableObject, Identifiable {
    @Published var match: Match
    
    init(match: Match) {
        self.match = match
    }
    
    func draw() {
        match.isDraw = true
        match.winner = nil
    }
    
    func setLeftWinner() {
        match.isDraw = false
        match.winner = match.left
    }
    
    func setRightWinner() {
        match.isDraw = false
        match.winner = match.right
    }
    
    func negateScore(_ side: ScoreSide) {
        if side == .left {
            match.leftScore.negate()
        } else {
            match.rightScore.negate()
        }
    }
}
