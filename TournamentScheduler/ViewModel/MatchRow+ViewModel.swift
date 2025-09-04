import Combine

extension MatchRow {
    
    final class ViewModel: ObservableObject, Identifiable {
        @Published var match: Match
        @Published var leftScoreText: String
        @Published var rightScoreText: String
        
        init(match: Match) {
            self.match = match
            self.leftScoreText = String(match.leftScore)
            self.rightScoreText = String(match.rightScore)
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
        
        func updateMatchScoresFromText() {
            match.leftScore = Int(leftScoreText) ?? 0
            match.rightScore = Int(rightScoreText) ?? 0
        }
        
        func syncTextFromMatchScores() {
            leftScoreText = String(match.leftScore)
            rightScoreText = String(match.rightScore)
        }
    }
}
