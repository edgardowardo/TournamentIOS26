
import SwiftUI
import Charts

struct ChartWinsView: View {
    
    let vm: StatisticsProviding
    let countPrefix: Int // TODO: not yet filtered with prefix.
    let isShowAll: Bool
    let barHeight: CGFloat
    
    let stacking: MarkStackingMethod = .standard
    
    @State private var isAnimated = false
    
    var body: some View {
        Chart {
            ForEach(vm.ranks) { r in
                BarMark(
                    x: .value("Wins", r.countWins),
                    y: .value("Player", r.rankAndName),
                    height: .fixed(barHeight),
                    stacking: stacking
                )
                .foregroundStyle(.green)
                
                if isShowAll {
                    BarMark(
                        x: .value("Losses", r.countLost),
                        y: .value("Player", r.rankAndName),
                        height: .fixed(barHeight),
                        stacking: stacking
                    )
                    .foregroundStyle(.red)

                    BarMark(
                        x: .value("Draws", r.countDrawn),
                        y: .value("Player", r.rankAndName),
                        height: .fixed(barHeight),
                        stacking: stacking
                    )
                    .foregroundStyle(.blue)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: false)
        .chartYAxis {
            AxisMarks(preset: .inset, position: .automatic) { _ in
                AxisValueLabel(horizontalSpacing: 10)
                    .font(.system(size: 16))
            }
        }
    }
}

extension RankInfo {
    var rankAndName: String { "\(self.rank). \(self.name)" }
}


#Preview {
    struct PreviewableChartWinsView: View {
        struct ViewModelProvider: StatisticsProviding {
            var ranks: [RankInfo] {
                [
                    .init(oldrank: 2, rank: 6, name: "1Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 7, name: "1Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 8, name: "1Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 9, name: "1Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 2, rank: 5, name: "2Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 6, name: "2Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 7, name: "2Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "2Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),

                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 2, name: "Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 3, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 5, rank: 5, name: "Eve",   countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0)
                ]
            }
            let schedule: Schedule = .roundRobin
            let nOverP: Int = 5
            var countMatches: Int = 16
            var countMatchByes: Int = 2
            var countMatchDraws: Int = 4
            var countMatchWins: Int = 31
        }
        var body: some View {
            NavigationStack {
                ChartWinsView(vm: ViewModelProvider(), countPrefix: 3, isShowAll: true, barHeight: 16)
            }
        }
    }
    return PreviewableChartWinsView()
}

