import SwiftUI

struct RoundsView: View {
    let rounds: [Round]
    let availableWidth: CGFloat
    let filterRound: Int

    @State private var editingScore: EditingScore? = nil

    var body: some View {
        ScrollView {
            ForEach(rounds.filter { filterRound == -1 || $0.value == filterRound }) { round in
                LazyVStack(alignment: .center, spacing: 10) {
                    Text("ROUND \(round.value)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(round.matches.sorted { $0.index < $1.index }) { match in
                        MatchRow(
                            match: match,
                            availableWidth: availableWidth,
                            editingScore: $editingScore
                        )
                    }
                }
                .padding(.top, 10)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(spacing: 2) {
                    Image(systemName: "slider.horizontal.3")
                    Image(systemName: "minus.circle")
                    Image(systemName: "equal.circle")
                }
                Text("Games are shown per round. Filter a round or show all with the filter button below. Click a button to win a match. Rotate landscape to edit, negate scores or draw.")
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
            .padding()
        }
        .toolbar {
            if let editing = editingScore,
               let match = rounds.flatMap(\.matches).first(where: { $0 == editing.match }) {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Draw", systemImage: "equal.circle") { match.isDraw = true }
                    Button("Negate", systemImage: "minus.circle") {
                        if editing.side == .left {
                            match.leftScore *= -1
                        } else {
                            match.rightScore *= -1
                        }
                    }
                    Spacer()
                    Button("Done", systemImage: "checkmark") { editingScore = nil }
                        .tint(.blue)
                }
            }
        }
    }
}

private enum ScoreSide { case left, right }
private struct EditingScore: Equatable {
    let match: Match
    let side: ScoreSide
}

private struct MatchRow: View {
    let match: Match
    let availableWidth: CGFloat
    @Binding var editingScore: EditingScore?

    @State private var leftScoreText: String = ""
    @State private var rightScoreText: String = ""

    @FocusState private var isLeftScoreFocused: Bool
    @FocusState private var isRightScoreFocused: Bool
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        HStack {
            if horizontalSizeClass == .regular || verticalSizeClass == .compact {
                TextField("0", text: $leftScoreText)
                    .frame(idealWidth: buttonWidth)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .onAppear { leftScoreText = String(match.leftScore) }
                    .onChange(of: leftScoreText) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        leftScoreText = filtered
                        match.leftScore = Int(filtered) ?? 0
                    }
                    .focused($isLeftScoreFocused)
                    .onChange(of: isLeftScoreFocused) { _, focused in
                        if focused {
                            editingScore = EditingScore(match: match, side: .left)
                        } else if editingScore?.match == match && editingScore?.side == .left {
                            editingScore = nil
                        }
                    }
            }
            
            Button(action: { match.winner = match.left }) {
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
            
            Button(action: { match.winner = match.right }) {
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
            
            if horizontalSizeClass == .regular || verticalSizeClass == .compact {
                TextField("0", text: $rightScoreText)
                    .frame(idealWidth: buttonWidth)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.numberPad)
                    .onAppear { rightScoreText = String(match.rightScore) }
                    .onChange(of: rightScoreText) { _, newValue in
                        rightScoreText = newValue.filter { $0.isNumber }
                        match.rightScore = Int(rightScoreText) ?? 0
                    }
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
    
    var isScoreVisible: Bool { horizontalSizeClass == .regular || verticalSizeClass == .compact }
    var scoreWidth: CGFloat { isScoreVisible ? 50 : 0 }
    var buttonWidth: CGFloat { (availableWidth - 66 - 16) / 2 - scoreWidth * 2 }
    
}

private extension Match {
    var leftName: String { left?.name ?? "BYE" }
    var rightName: String { right?.name ?? "BYE" }

    var leftTextTint: Color { self.winner === self.left ? .white : (self.left == nil ? .gray : .blue) }
    var rightTextTint: Color { self.winner === self.right ? .white : (self.right == nil ? .gray : .blue) }
    
    var leftTint: Color { self.winner === self.left ? .green : (self.isBye ? .blue : .gray.opacity(0.3)) }
    var rightTint: Color { self.winner === self.right ? .green : (self.isBye ? .blue : .gray.opacity(0.3)) }
}
