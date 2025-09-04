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
                    Text("NAME").frame(maxWidth: .infinity, alignment: .leading)
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
                        Text("\(rowVM.rank)")
                        Text(rowVM.name).frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(rowVM.countPlayed)")
                        Text("\(rowVM.countWins)")
                        Text("\(rowVM.countLost)")
                        Text("\(rowVM.countDrawn)")
                    }
                }
                
                // footer
                GridRow {
                    Text("Round Robin or American Double schedules show N number of matches per row in the /P column. (W)in, (L)ose, (D)raw, Points (F)or, Points (A)gainst, and Points (D)ifference. ")
                        .gridCellColumns(6)
                        .foregroundStyle(.secondary)
                        .font(.footnote)

                }
                
            }
            .padding()
        }
    }
}

#Preview {
    struct PreviewableStandingsView: View {
        struct ViewModelProvider: StandingsRowsViewModelProviding {
            var standings: [StandingsRowViewModel] {
                [
                    .init(oldrank: 1, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0),
                    .init(oldrank: 2, rank: 2, name: "Bob", countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 1, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0),
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

