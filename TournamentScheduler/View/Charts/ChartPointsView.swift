
import SwiftUI
import Charts

extension ChartPointsView {
    enum Subset {
        case top(count: Int), bottom(count: Int)
    }
}

extension RankInfo {
    var textWinPoints: String { pointsFor > 0 ? pointsFor.formatted() : "" }
    var textLosPoints: String { pointsAgainst > 0 ? pointsAgainst.formatted() : "" }
}

struct ChartPointsView: View, ChartHeightProviding {
    
    let vm: StatisticsProviding
    let subset: Subset?
    let isShowAllRow: Bool
    
    private var data: [RankInfo] {
        let ranks = vm.ranks
            .filter { isShowAllRow || !isShowAllRow && ($0.pointsFor > 0 || $0.pointsAgainst > 0) }
            .sorted { $0.pointsDifference > $1.pointsDifference }
        guard let subset else { return ranks }
        switch subset {
        case let .top(count):
            return Array(ranks.prefix(count))
        case let .bottom(count):
            return Array(ranks.suffix(count))
        }
    }
    
    private var maxValue: Int {  max(data.map(\.pointsFor).max() ?? 0, data.map(\.pointsAgainst).max() ?? 0) }
    
    var body: some View {
        VStack(alignment: .leading) {
            if subset == nil {
                Text("The points for and against are counted regardless of win or lose and are ordered only by point difference. Values are mirrored from the center of the chart. Points against are shown on the left side (points from opposing side are negated). Points for on the right. Actual values annotated.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
            }
            
            Chart {
                ForEach(data) { d in
                    BarMark(
                        x: .value("Points", d.pointsFor),
                        y: .value("Player", d.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(d.textWinPoints)
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Points"))
                    
                    // Losses (negative values → left side)
                    BarMark(
                        x: .value("Against", -d.pointsAgainst),
                        y: .value("Player", d.rankAndName)
                    )
                    .annotation(position: .overlay) {
                        Text(d.textLosPoints)
                            .font(Font.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(by: .value("Result", "Against"))
                    
                }
            }
            .chartXAxis(subset == nil ? .visible : .hidden)
            .chartXAxis {
                AxisMarks(values: Array(stride(from: -maxValue, through: maxValue, by: 2))) { value in
                    AxisValueLabel {
                        if let intVal = value.as(Int.self) {
                            Text("\(abs(intVal))") // Show positive labels on both sides
                        }
                    }
                }
            }
            .frame(height: chartHeightFor(data.count))
            .chartLegend(subset == nil ? .visible : .hidden)
            .chartLegend(position: .top)
            .chartForegroundStyleScale([
                "Points": .mint,
                "Against": .indigo
            ])
        }
    }
}




#Preview {
    struct PreviewableChartPointsView: View {
        struct ViewModelProvider: StatisticsProviding {
            var ranks: [RankInfo] {
                [
                    .init(oldrank: 2, rank: 6, name: "1Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 1, pointsDifference: 5),
                    .init(oldrank: 1, rank: 7, name: "1Bob",   countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 2, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 8, name: "1Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 3, countDrawn: 0, countBye: 1, pointsFor: 2, pointsAgainst: 1, pointsDifference: 2),
                    .init(oldrank: 4, rank: 9, name: "1Dave",  countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 4, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 2, rank: 5, name: "2Alice", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 6, name: "2Bob",   countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 1, pointsDifference: 3),
                    .init(oldrank: 3, rank: 7, name: "2Carol", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 0, pointsAgainst: 1, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "2Dave",  countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 0, countDrawn: 0, countBye: 1, pointsFor: 1, pointsAgainst: 0, pointsDifference: 1),
                                        
                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 0, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 2, name: "Bob", countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 1, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 3, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 2, countDrawn: 1, countBye: 1, pointsFor: 4, pointsAgainst: 2, pointsDifference: 8),
                    .init(oldrank: 4, rank: 4, name: "Dave", countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 3, countDrawn: 1, countBye: 1, pointsFor: 2, pointsAgainst: 0, pointsDifference: 9),
                    .init(oldrank: 5, rank: 5, name: "Eve", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, countBye: 1, pointsFor: 3, pointsAgainst: 2, pointsDifference: 10)
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
                let vm = ViewModelProvider()
                ChartPointsView(vm: vm, subset: nil, isShowAllRow: true)
                    .padding()
            }
        }
    }
    return PreviewableChartPointsView()
}
