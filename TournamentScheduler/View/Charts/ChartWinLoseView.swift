import SwiftUI
import Charts

struct ChartWinLoseView: View {
        
    let vm: StatisticsProviding
        
    @State private var isShowAll: Bool = false
    
    private var data: [RankInfo] { vm.ranks.filter { isShowAll || !isShowAll && ($0.countWins > 0 || $0.countLost > 0) } }
    private var maxValue: Int {  max(data.map(\.countLost).max() ?? 0, data.map(\.countWins).max() ?? 0) }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Toggle("Show all", isOn: $isShowAll.animation(.bouncy))
                .padding()
            
            Chart {
                ForEach(data) { d in
                    BarMark(
                        x: .value("Win", d.countWins),
                        y: .value("Player", d.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(d.countWins.formatted())
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Win"))
                    
                    // Losses (negative values → left side)
                    BarMark(
                        x: .value("Lose", -d.countLost),
                        y: .value("Player", d.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(d.countLost.formatted())
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Lose"))
                    
                }
            }
            .chartXAxis {
                AxisMarks(values: Array(stride(from: -maxValue, through: maxValue, by: 2))) { value in
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text("\(abs(intVal))") // Show positive labels on both sides
                        }
                    }
                }
            }
            .frame(height: chartHeightFor(vm.ranks.count))
            .padding()
            .chartLegend(position: .bottom)
            .chartForegroundStyleScale([
                "Win": .green,
                "Lose": .red
            ])
        }
    }
    
    private func chartHeightFor(_ count: Int) -> CGFloat {
        let barHeight: CGFloat = 16
        let barSpacing: CGFloat = 20
        let minChartHeight: CGFloat = 120
        let height = max(minChartHeight, CGFloat(count) * (barHeight + barSpacing) + 60)
        return height
    }

    
}

#Preview {
    struct PreviewableChartWinLoseView: View {
        struct ViewModelProvider: StatisticsProviding {
            var ranks: [RankInfo] {
                [
                    .init(oldrank: 2, rank: 6, name: "1Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 7, name: "1Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 8, name: "1Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 9, name: "1Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 2, rank: 5, name: "2Alice", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 6, name: "2Bob",   countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 7, name: "2Carol", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "2Dave",  countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                                        
                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 0, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 2, name: "Bob", countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 1, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 3, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 2, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "Dave", countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 3, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 5, rank: 5, name: "Eve", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0)
                ]
            }
            let schedule: Schedule = .roundRobin
            let nOverP: Int = 5
            let poolName: String = "Preliminaries"
            var countMatches: Int = 16
            var countMatchByes: Int = 4
            var countMatchDraws: Int = 4
            var countMatchWins: Int = 3
        }
        var body: some View {
            NavigationStack {
                ChartWinLoseView(vm: ViewModelProvider())
            }
        }
    }
    return PreviewableChartWinLoseView()
}
