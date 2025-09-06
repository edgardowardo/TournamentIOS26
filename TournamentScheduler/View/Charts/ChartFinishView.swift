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
        .chartYScale(domain: 0...maxAmount)
        .frame(height: 200)
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
