import SwiftUI
import SwiftData

struct MatchRowView: View {
    
    @Bindable var match: Match
    @Binding var editingScore: EditingScore?
    let availableWidth: CGFloat

    @State private var leftScoreText: String = ""
    @State private var rightScoreText: String = ""
    @FocusState private var isLeftScoreFocused: Bool
    @FocusState private var isRightScoreFocused: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
        
    var body: some View {
        HStack {
            if isLandcape {
                TextField("0", text: .init(
                    get: { String(match.leftScore) },
                    set: {
                        match.leftScore = Int($0) ?? 0
                        match.round?.pool?.timestamp = .now
                        match.round?.pool?.tournament?.timestamp = .now
                    }
                ))
                .frame(idealWidth: buttonWidth)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .focused($isLeftScoreFocused)
                .onChange(of: isLeftScoreFocused) { _, focused in
                    if focused {
                        editingScore = EditingScore(match: match, side: .left)
                    } else if editingScore?.match == match && editingScore?.side == .left {
                        editingScore = nil
                    }
                }
            }
            
            Button(action: {
                withAnimation(.easeInOut) {
                    match.setLeftAsWinner()
                }
            }) {
                Text(match.leftName)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(match.left == nil)
            .frame(width: buttonWidth)
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .foregroundStyle(match.leftTextTint)
            .tint(match.leftTint)
            
            Text("\(match.index)")
                .frame(width: 40, alignment: .center)
                .multilineTextAlignment(.center)
            
            Button(action: {
                withAnimation(.easeInOut) {
                    match.setRightAsWinner()
                }
            }) {
                Text(match.rightName)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(match.right == nil)
            .frame(width: buttonWidth)
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .foregroundStyle(match.rightTextTint)
            .tint(match.rightTint)
            
            if isLandcape {
                TextField("0", text: Binding(
                    get: { String(match.rightScore) },
                    set: {
                        match.rightScore = Int($0) ?? 0
                        match.round?.pool?.timestamp = .now
                        match.round?.pool?.tournament?.timestamp = .now
                    }
                ))
                .frame(idealWidth: buttonWidth)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.leading)
                .keyboardType(.numberPad)
                .focused($isRightScoreFocused)
                .onChange(of: isRightScoreFocused) { _, focused in
                    if focused {
                        editingScore = EditingScore(match: match, side: .right)
                    } else if editingScore?.match == match && editingScore?.side == .right {
                        editingScore = nil
                    }
                }
            }
        }
        .disabled(match.isBye)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .center)
        .onChange(of: editingScore) { _, newValue in
            if newValue == nil {
                isLeftScoreFocused = false
                isRightScoreFocused = false
            }
        }
    }
    
    var isLandcape: Bool { horizontalSizeClass == .regular || verticalSizeClass == .compact }
    var isScoreVisible: Bool { horizontalSizeClass == .regular || verticalSizeClass == .compact }
    var scoreWidth: CGFloat { isScoreVisible ? 50 : 0 }
    var buttonWidth: CGFloat { (availableWidth - 66 - 16) / 2 - scoreWidth * 2 }
    
}

private extension Match {
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

    var leftTextTint: Color {
        if isDraw || winner == self.left && !isBye {
            return .white
        } else if left == nil {
            return .gray
        } else {
            return .blue
        }
    }
    var rightTextTint: Color {
        if isDraw || winner == self.right && !isBye {
            return .white
        } else if right == nil {
            return .gray
        } else {
            return .blue
        }
    }
    
    var leftTint: Color { self.winner === self.left ? .green.opacity( isBye ? 0.5 : 1 ) : (self.isDraw ? .blue : .gray.opacity(0.3)) }
    var rightTint: Color { self.winner === self.right ? .green.opacity( isBye ? 0.5 : 1 ) : (self.isDraw ? .blue : .gray.opacity(0.3)) }
    
    func setLeftAsWinner() {
        isDraw = false
        winner = left
        advanceWinner()
        round?.pool?.timestamp = .now
        round?.pool?.tournament?.timestamp = .now
    }
    
    func setRightAsWinner() {
        isDraw = false
        winner = right
        advanceWinner()
        round?.pool?.timestamp = .now
        round?.pool?.tournament?.timestamp = .now
    }
        
    /// at the current level we set the winner and reset the ancestors accordingly
    private func advanceWinner() {
        guard let winner, let nextMatch else { return }
        
        /// the next match's link on the left side correlates to the current "self" match
        /// current winner is changing (not equal) to the next left link, so we reset.
        if nextMatch.prevLeftMatch == self, nextMatch.left != winner {

            /// start recursion
            if nextMatch.winner != nil {
                nextMatch.resetMatch()
            }
            nextMatch.left = winner
            nextMatch.isDraw = false
            nextMatch.winner = nil
            
        } else if nextMatch.prevRightMatch == self, nextMatch.right != winner {
            if nextMatch.winner != nil {
                nextMatch.resetMatch()
            }
            nextMatch.right = winner
            nextMatch.isDraw = false
            nextMatch.winner = nil
        }
    }
    
    /// recursively resetMatch for the next match that needs resetting, up until there is no nextMatch
    private func resetMatch() {
        /// base case
        guard let nextMatch else { return }
        
        /// the next match's link on the left side correlates to the current "self" match
        /// and the current winner has advanced to the next match which needs resetting
        if nextMatch.prevLeftMatch == self, self.winner == nextMatch.left {

            /// recursion to the top of the tree
            if nextMatch.winner != nil {
                nextMatch.resetMatch()
            }
            nextMatch.left = nil
            nextMatch.isDraw = false
            nextMatch.winner = nil
            
        } else if nextMatch.prevRightMatch == self, self.winner == nextMatch.right {

            if nextMatch.winner != nil {
                nextMatch.resetMatch()
            }
            nextMatch.right = nil
            nextMatch.isDraw = false
            nextMatch.winner = nil
        }
    }
        
    /// nextMatch is calculated since our schema has the previous left and right match which describes the tree.
    /// to calculate, look at the current round where the match belongs. increment by one since the next match is on
    /// the next round. on the next round, the match that links with the previous left or right match is returned.
    private var nextMatch: Match? {
        guard let nextRoundIndex = self.round?.value.advanced(by: 1),
              let nextRound = self.round?.pool?.rounds.filter({ $0.value == nextRoundIndex }).first
        else { return nil }
        return nextRound.matches.filter { $0.prevLeftMatch == self || $0.prevRightMatch == self }.first
    }
    
}

#Preview {
    struct PreviewableMatchRow: View {
        @State var editingScore: EditingScore? = nil
        var body: some View {
            let container = try! ModelContainer(for: Match.self, Participant.self)
            let context = container.mainContext
            // Remove existing matches
            let allMatches = try? context.fetch(FetchDescriptor<Match>())
            allMatches?.forEach { context.delete($0) }
            let left = Participant(name: "Alice", seed: 1)
            let right = Participant(name: "Bob", seed: 2)
            context.insert(left)
            context.insert(right)
            let match = Match(index: 1, round: nil, left: left, right: right, leftScore: 5, rightScore: 3)
            context.insert(match)
            return MatchRowView(match: match, editingScore: $editingScore, availableWidth: 400)
                .modelContainer(container)
                .padding()
        }
    }
    return PreviewableMatchRow()
}
