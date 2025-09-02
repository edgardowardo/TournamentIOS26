import SwiftUI


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

final class RoundViewModel: ObservableObject, Identifiable {
    @Published var item: Round
    @Published var matchVMs: [MatchViewModel]
    
    init(item: Round) {
        self.item = item
        self.matchVMs = item.matches
            .sorted { $0.index < $1.index }
            .map { .init(match: $0) }
    }
}

final class RoundsViewModel: ObservableObject {
    @Published var roundVMs: [RoundViewModel]
    
    init(pool: Pool, filterRound: Int) {
        roundVMs = pool.rounds
            .filter { filterRound == -1 || $0.value == filterRound }
            .sorted { $0.value < $1.value }
            .map { .init(item: $0) }
    }
}

struct RoundsView: View {
    @ObservedObject private var vm: RoundsViewModel
    let availableWidth: CGFloat

    @State private var editingScore: EditingScore? = nil
    
    init(vm: RoundsViewModel, availableWidth: CGFloat) {
        self._vm = ObservedObject(wrappedValue: vm)
        self.availableWidth = availableWidth
    }
    
    var body: some View {
        ScrollView {
            ForEach(vm.roundVMs) { roundVM in
                LazyVStack(alignment: .center, spacing: 10) {
                    Text("ROUND \(roundVM.item.value)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(roundVM.matchVMs) { matchVM in
                        MatchRow(
                            vm: matchVM,
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
               let matchVM = vm.roundVMs.flatMap(\.matchVMs).first(where: { $0.match == editing.match }) {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Draw", systemImage: "equal.circle") { matchVM.draw() }
                    Button("Negate", systemImage: "minus.circle") { matchVM.negateScore(editing.side) }
                    Spacer()
                    Button("Done", systemImage: "checkmark") { editingScore = nil }
                        .tint(.blue)
                }
            }
        }
    }
}

enum ScoreSide { case left, right }
struct EditingScore: Equatable {
    let match: Match
    let side: ScoreSide
}

struct MatchRow: View {
    @ObservedObject var vm: MatchViewModel
    let availableWidth: CGFloat
    @Binding var editingScore: EditingScore?

    @FocusState private var isLeftScoreFocused: Bool
    @FocusState private var isRightScoreFocused: Bool
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    init(vm: MatchViewModel, availableWidth: CGFloat, editingScore: Binding<EditingScore?>) {
        self._vm = ObservedObject(wrappedValue: vm)
        self.availableWidth = availableWidth
        self._editingScore = editingScore
    }
    
    var body: some View {
        HStack {
            if horizontalSizeClass == .regular || verticalSizeClass == .compact {
                TextField("0", text: Binding(
                    get: { String(vm.match.leftScore) },
                    set: { vm.match.leftScore = Int($0) ?? 0 }
                ))
                .frame(idealWidth: buttonWidth)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .focused($isLeftScoreFocused)
                .onChange(of: isLeftScoreFocused) { _, focused in
                    if focused {
                        editingScore = EditingScore(match: vm.match, side: .left)
                    } else if editingScore?.match == vm.match && editingScore?.side == .left {
                        editingScore = nil
                    }
                }
            }
            
            Button(action: vm.setLeftWinner) {
                Text(vm.match.leftName)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(vm.match.left == nil)
            .frame(width: buttonWidth)
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .foregroundStyle(vm.match.leftTextTint)
            .tint(vm.match.leftTint)
            
            Text("\(vm.match.index)")
                .frame(width: 40, alignment: .center)
                .multilineTextAlignment(.center)
            
            Button(action: vm.setRightWinner) {
                Text(vm.match.rightName)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(vm.match.right == nil)
            .frame(width: buttonWidth)
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .foregroundStyle(vm.match.rightTextTint)
            .tint(vm.match.rightTint)
            
            if horizontalSizeClass == .regular || verticalSizeClass == .compact {
                TextField("0", text: Binding(
                    get: { String(vm.match.rightScore) },
                    set: { vm.match.rightScore = Int($0) ?? 0 }
                ))
                .frame(idealWidth: buttonWidth)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.leading)
                .keyboardType(.numberPad)
                .focused($isRightScoreFocused)
                .onChange(of: isRightScoreFocused) { _, focused in
                    if focused {
                        editingScore = EditingScore(match: vm.match, side: .right)
                    } else if editingScore?.match == vm.match && editingScore?.side == .right {
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
}

