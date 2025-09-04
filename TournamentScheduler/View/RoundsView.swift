import SwiftUI

enum ScoreSide { case left, right }

struct EditingScore: Equatable {
    let match: Match
    let side: ScoreSide
}

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
                        MatchRow(inmatch: match, availableWidth: availableWidth, editingScore: $editingScore)
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
                Text("Filter a round or show all with the filter button. Click a participant to win a match. Rotate landscape to edit, negate scores or draw.")
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
            .padding()
        }
        .toolbar {
            if let editing = editingScore,
               let match = rounds.flatMap(\.matches).first(where: { $0 == editing.match }) {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Draw", systemImage: "equal.circle") {
                        withAnimation {
                            match.setDraw()
                        }
                    }
                    Button("Negate", systemImage: "minus.circle") {
                        if editing.side == .left {
                            match.leftScore.negate()
                        } else {
                            match.rightScore.negate()
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

private extension Match {
    func setDraw() {
        isDraw = true
        winner = nil
    }
}



/*
#Preview {
    let roundsViewModel: RoundsView.ViewModel = {
        let seedCount = 8
        let newItem: Pool = .init(
            name: "name",
            schedule: .roundRobin,
            seedCount: seedCount,
            isHandicap: false,
            timestamp: .now,
            tournament: nil,
            participants: Array(1...seedCount).map { Participant(name: "name\($0)", seed: $0) })
        ScheduleBuilder(pool: newItem).schedule()
        return .init(pool: newItem, filterRound: -1)
    }()
    
    NavigationStack {
        RoundsView(vm: roundsViewModel, availableWidth: 400)
        .navigationTitle(Text("Rounds"))
    }
}
*/
