import SwiftUI

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


#Preview {
    struct MatchRowPreviewContainer: View {
        @State private var editingScore: EditingScore? = nil
        var body: some View {
            let left = Participant(name: "Alice", seed: 1)
            let right = Participant(name: "Bob", seed: 2)
            let match = Match(index: 1, round: nil, left: left, right: right, leftScore: 5, rightScore: 3)
            let vm = MatchViewModel(match: match)
            MatchRow(vm: vm, availableWidth: 400, editingScore: $editingScore)
                .padding()
        }
    }
    return MatchRowPreviewContainer()
}
