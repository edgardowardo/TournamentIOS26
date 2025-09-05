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
                Text("Filter a round or show all with the filter button. Click a participant to win a match. Rotate landscape to edit, negate scores or draw. Scores break ties in Ranks.")
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

import SwiftData

#Preview {
    let view: some View = {
        let container = try! ModelContainer(for: Pool.self, Round.self, Match.self, Participant.self)
        let context = container.mainContext
        // Clear out any existing pools
        let fetchDescriptor = FetchDescriptor<Pool>()
        let allPools = (try? context.fetch(fetchDescriptor)) ?? []
        for pool in allPools { context.delete(pool) }
        // Sample Pool with 4 participants and 1 round, 2 matches
        let pool = Pool(name: "Preview Pool", schedule: .roundRobin, seedCount: 4, isHandicap: false, timestamp: .now, tournament: nil, participants: [
            Participant(name: "Alice", seed: 1),
            Participant(name: "Bob", seed: 2),
            Participant(name: "Carol", seed: 3),
            Participant(name: "Dan", seed: 4)
        ])
        let m1 = Match(index: 1, round: nil, left: pool.participants[0], right: pool.participants[1], leftScore: 5, rightScore: 3)
        let m2 = Match(index: 2, round: nil, left: pool.participants[2], right: pool.participants[3], leftScore: 4, rightScore: 6)
        let round1 = Round(value: 1, pool: pool, matches: [m1, m2])
        pool.rounds = [round1]
        context.insert(pool)
        return NavigationStack {
            RoundsView(rounds: pool.rounds, availableWidth: 400, filterRound: -1)
                .navigationTitle("Rounds")
        }
        .modelContainer(container)
    }()
    view
}
