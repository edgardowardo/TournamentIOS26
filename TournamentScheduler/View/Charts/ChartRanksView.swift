import SwiftUI
import Charts
 
extension ChartRanksView {
    enum Column {
        case win, lose, draw, bye, pending
    }
}

extension RankInfo {
    var rankAndName: String { "\(self.rank). \(self.name)" }
}

struct ChartRanksView: View, ChartHeightProviding {
    
    let vm: StatisticsProviding
    let count: Int
    let column: Column?
    let isShowAllRow: Bool
        
    @State private var isAnimated = false
    
    private var ranks: [RankInfo] {
        let list = vm.ranks.filter { isShowAllRow || !isShowAllRow && ($0.countWins > 0 || $0.countLost > 0 || $0.countDrawn > 0 || $0.countBye > 0) }
        guard let column else { return list }
        
        switch column {
        case .win:
            return Array(list.filter { $0.countWins > 0 }.prefix(count))
        case .lose:
            return Array(list.filter { $0.countLost > 0 }.suffix(count))
        case .draw:
            return Array(list.filter { $0.countDrawn > 0 }.prefix(count))
        case .bye:
            return Array(list.filter { $0.countBye > 0 }.prefix(count))
        case .pending:
            return Array(list.filter { $0.countWins == 0 && $0.countLost == 0 && $0.countDrawn == 0 && $0.countBye == 0 })
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if column == nil {
                Text("All Win/Lose/Draw/Bye are stacked on the same bar horizontally. Current rankings and are not final until all matches are finished. Actual values annotated. ")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
            }
            
            Chart(ranks) { r in
                if column == .win || column == nil {
                    BarMark(
                        x: .value("Win", r.countWins),
                        y: .value("Player", r.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(r.textWin)
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Win"))
                }
                
                if column == .lose || column == nil {
                    BarMark(
                        x: .value("Lose", r.countLost),
                        y: .value("Player", r.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(r.textLos)
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Lose"))
                }
                
                if column == .draw || column == nil {
                    BarMark(
                        x: .value("Draw", r.countDrawn),
                        y: .value("Player", r.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(r.textDraw)
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Draw"))
                }
                
                if column == .bye || column == nil {
                    BarMark(
                        x: .value("Bye", r.countBye),
                        y: .value("Player", r.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(r.textBye)
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Bye"))
                }
            }
            .frame(height: chartHeightFor(ranks.count))
            .chartXAxis(column == nil ? .visible : .hidden)
            .chartLegend(column == nil ? .visible : .hidden)
            .chartLegend(position: .top)
            .chartForegroundStyleScale([
                "Win": .green,
                "Lose": .red,
                "Draw": .blue,
                "Bye": .orange
            ])
        }
    }
}

#Preview {
    struct PreviewableChartWinsView: View {
        struct ViewModelProvider: StatisticsProviding {
            var ranks: [RankInfo] {
                [
                    .init(oldrank: 2, rank: 1, name: "1Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 2, name: "1Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 3, name: "1Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "1Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 2, rank: 5, name: "2Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 6, name: "2Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 7, name: "2Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 8, name: "2Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),

                    .init(oldrank: 2, rank: 9, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 10, name: "Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 11, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 12, name: "Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 5, rank: 13, name: "Eve",   countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0)
                ]
            }
            let schedule: Schedule = .roundRobin
            let nOverP: Int = 5
            let poolName: String = "Preliminaries"
            var countMatches: Int = 16
            var countMatchByes: Int = 2
            var countMatchDraws: Int = 4
            var countMatchWins: Int = 31
        }
        var body: some View {
            let vm = ViewModelProvider()
            NavigationStack {
                ChartRanksView(vm: vm, count: 0, column: nil, isShowAllRow: true)
            }
        }
    }
    return PreviewableChartWinsView()
}

