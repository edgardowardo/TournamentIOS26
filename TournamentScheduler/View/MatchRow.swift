import SwiftUI
import SwiftData

struct MatchRow: View {
    let inmatch: Match
    let availableWidth: CGFloat
    
    @Query private var matches: [Match]
    
    @Binding var editingScore: EditingScore?

    @State private var leftScoreText: String = ""
    @State private var rightScoreText: String = ""
    
    @FocusState private var isLeftScoreFocused: Bool
    @FocusState private var isRightScoreFocused: Bool
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
        
    var body: some View {
        let match = matches.first(where: { $0 == inmatch })!
        HStack {
            if isLandcape {
                TextField("0", text: Binding(
                    get: { String(match.leftScore) },
                    set: { match.leftScore = Int($0) ?? 0 }
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
                    match.setLeftWinner()
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
                    match.setRightWinner()
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
                    set: { match.rightScore = Int($0) ?? 0 }
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
    var leftName: String { left?.name ?? "BYE" }
    var rightName: String { right?.name ?? "BYE" }

    var leftTextTint: Color {
        if isDraw || winner == self.left {
            return .white
        } else if left == nil {
            return .gray
        } else {
            return .blue
        }
    }
    var rightTextTint: Color {
        if isDraw || winner == self.right {
            return .white
        } else if right == nil {
            return .gray
        } else {
            return .blue
        }
    }
    
    var leftTint: Color { self.winner === self.left ? .green : (self.isDraw ? .blue : .gray.opacity(0.3)) }
    var rightTint: Color { self.winner === self.right ? .green : (self.isDraw ? .blue : .gray.opacity(0.3)) }
    
    func setLeftWinner() {
        isDraw = false
        winner = left
    }
    
    func setRightWinner() {
        isDraw = false
        winner = right
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
            return MatchRow(inmatch: match, availableWidth: 400, editingScore: $editingScore)
                .modelContainer(container)
                .padding()
        }
    }
    return PreviewableMatchRow()
}
