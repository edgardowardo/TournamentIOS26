import SwiftUI
import Charts
 
extension RankInfo {
    enum Status: String, CaseIterable {
        case win, lose, all
    }
}

extension RankInfo {
    var rankAndName: String { "\(self.rank). \(self.name)" }
}

struct ChartRanksView: View {
    
    let vm: StatisticsProviding
    let countPrefix: Int // TODO: not yet filtered with prefix.
    let show: RankInfo.Status
        
    @State private var isAnimated = false
    
    var body: some View {
        Chart(vm.ranks) { r in
            if show == .win || show == .all {
                BarMark(
                    x: .value("Win", r.countWins),
                    y: .value("Player", r.rankAndName)
                )
                .foregroundStyle(by: .value("Result", "Win"))
            }
            
            if show == .lose || show == .all {
                BarMark(
                    x: .value("Lose", r.countLost),
                    y: .value("Player", r.rankAndName)
                )
                .foregroundStyle(by: .value("Result", "Lose"))
            }
             
            if show == .all {
                BarMark(
                    x: .value("Draw", r.countDrawn),
                    y: .value("Player", r.rankAndName)
                )
                .foregroundStyle(by: .value("Result", "Draw"))
            }
        }
        .chartLegend(show == .all ? .visible : .hidden)
        .chartLegend(position: .bottom)
        .chartForegroundStyleScale([
            "Win": .green,
            "Lose": .red,
            "Draw": .blue
        ])
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
            NavigationStack {
                ChartRanksView(vm: ViewModelProvider(), countPrefix: 3, show: .all)
            }
        }
    }
    return PreviewableChartWinsView()
}

