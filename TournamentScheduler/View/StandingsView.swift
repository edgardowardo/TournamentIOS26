import SwiftUI
import SwiftData

struct StandingsView: View {
    let vm: StandingsRowsViewModelProviding
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                
                // headers
                GridRow {
                    Text("RANK")
                        .gridColumnAlignment(.leading)
                    Text("NAME")
                        .gridColumnAlignment(.leading)
                    Text(vm.schedule.showNoverPHeader ? "\(vm.nOverP)/P" : "P")
                    Text("W")
                    Text("L")
                    Text("D")
                }
                .font(.headline)

                // rows
                ForEach(vm.standings) { rowVM in
                    Divider()
                           .gridCellUnsizedAxes(.horizontal)
                    GridRow {
                        HStack(spacing: 2) {
                            Text("\(rowVM.rank)")
                            if rowVM.rankDelta != 0 {
                                Image(systemName: rowVM.rankDeltaSymbolName)
                                    .resizable()
                                    .frame(width: 7, height: 10)
                                    .foregroundColor(rowVM.rankColor)
                                Text("\(rowVM.rankDelta)")
                                    .font(.caption2)
                                    .foregroundStyle(rowVM.rankColor)
                            }
                        }
                        .gridColumnAlignment(.leading)

                        Text(rowVM.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(rowVM.countPlayed)")
                        Text("\(rowVM.countWins)")
                        Text("\(rowVM.countLost)")
                        Text("\(rowVM.countDrawn)")
                    }
                }
                
                // footer
                GridRow {
                    Text("Rotate landscape to show points (F)or, (A)gainst, and D(I)fference. Round Robin or American Double schedules show N number of matches per row in the /P column.")
                        .gridCellColumns(6)
                        .foregroundStyle(.secondary)
                        .font(.footnote)

                }
                
            }
            .padding()
        }
    }
}

extension StandingsRowViewModel {
    var rankDelta: Int { oldrank - rank }
    var rankColor: Color {
        if rankDelta > 0 {
            return .green
        } else if rankDelta < 0 {
            return .red
        }
        return .clear
    }
    var rankDeltaSymbolName: String {
        if rankDelta > 0 {
            return "arrow.up"
        } else if rankDelta < 0 {
            return "arrow.down"
        }
        return ""
    }
}

#Preview {
    struct PreviewableStandingsView: View {
        struct ViewModelProvider: StandingsRowsViewModelProviding {
            var standings: [StandingsRowViewModel] {
                [
                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0),
                    .init(oldrank: 1, rank: 2, name: "Bob", countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 1, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0),
                    .init(oldrank: 3, rank: 3, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 2, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0),
                    .init(oldrank: 4, rank: 4, name: "Dave", countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 3, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0),
                    .init(oldrank: 5, rank: 5, name: "Eve", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0)
                ]
            }
            let schedule: Schedule = .roundRobin
            let nOverP: Int = 5
        }
        var body: some View {
            NavigationStack {
                StandingsView(vm: ViewModelProvider())
                    .navigationTitle("Standings")
            }
        }
    }
    return PreviewableStandingsView()
}

