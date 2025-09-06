import SwiftUI
import Charts

struct ChartFinishView: View {

    let vm: StatisticsProviding

    @State private var isAnimated = false
    @State private var data: [ChartItem]

    init(vm: StatisticsProviding) {
        self.vm = vm
        var countNotPlayed: Int { vm.countMatches - (vm.countMatchDraws + vm.countMatchWins) }
        _data = .init(initialValue: [
            .init(type: "Wins", amount: vm.countMatchWins),
            .init(type: "Draws", amount: vm.countMatchDraws),
            .init(type: "Not Played", amount: countNotPlayed)
        ])
    }
    
    var maxAmount: Int { data.map(\.amount).max() ?? 0 }

    var body: some View {
        Chart(data, id: \.type) { dataItem in
            SectorMark(angle: .value("Type", dataItem.isAnimated ? dataItem.amount : 0),
                       innerRadius: .ratio(0.618),
                       outerRadius: .inset(10),
                       angularInset: 1)
                .cornerRadius(5)
                .foregroundStyle(by: .value("Type", dataItem.type))
                .opacity(dataItem.isAnimated ? 1 : 0)
        }
        .chartLegend(alignment: .center)
        .chartYScale(domain: 0...maxAmount)
        .frame(width: 250, height: 250)
        .onAppear(perform: animateChart)
        .chartBackground { p in
            GeometryReader { g in
                if let plotFrame = p.plotFrame {
                    let frame = g[plotFrame]
                    VStack {
                        Text("\(vm.countFinishedMatches)")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Text("Finished")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
    }
    
    private func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true
        
        $data.enumerated().forEach { index, element in
            let delay = Double(index) * 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    element.wrappedValue.isAnimated = true
                }
            }
        }
    }
}


#Preview {
    struct PreviewableChartFinishView: View {
        struct ViewModelProvider: StatisticsProviding {
            var ranks: [RankInfo] {
                [
                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 2, name: "Bob", countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 1, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 3, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 2, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "Dave", countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 3, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 5, rank: 5, name: "Eve", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0)
                ]
            }
            let schedule: Schedule = .roundRobin
            let nOverP: Int = 5
            var countMatchWins: Int = 31
            var countMatchDraws: Int = 4
            var countMatches: Int = 16
        }
        var body: some View {
            NavigationStack {
                ChartFinishView(vm: ViewModelProvider())
            }
        }
    }
    return PreviewableChartFinishView()
}

