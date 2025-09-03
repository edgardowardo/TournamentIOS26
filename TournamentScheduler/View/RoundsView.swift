import SwiftUI

enum ScoreSide { case left, right }

struct EditingScore: Equatable {
    let match: Match
    let side: ScoreSide
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
                Text("Filter a round or show all with the filter button. Click a participant to win a match. Rotate landscape to edit, negate scores or draw.")
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

#Preview {
    let roundsViewModel: RoundsViewModel = {
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
