import SwiftUI
import Charts

struct ChartCompleteView: View {

    let vm: StatisticsProviding
    let isFullScreen: Bool
    let dimension: CGFloat

    @State private var isAnimated = false
    @State private var data: [ChartItem]
    @State private var selectedAngle: Double? = nil
    private let typeRanges: [(type: String, range: Range<Double>)]
    private let totalCount: Int
    
    init(vm: StatisticsProviding, isFullScreen: Bool, dimension: CGFloat, isPreview: Bool = false) {
        self.vm = vm
        self.isFullScreen = isFullScreen
        var countNotPlayed: Int { vm.countMatches - (vm.countMatchDraws + vm.countMatchWins + vm.countMatchByes) }
        let items: [ChartItem] = [
            .init(type: "Win", count: vm.countMatchWins),
            .init(type: "Draw", count: vm.countMatchDraws),
            .init(type: "Bye", count: vm.countMatchByes),
            .init(type: "Pending", count: countNotPlayed)
        ]
        _data = .init(initialValue: items)
        var total = 0
        if isPreview {
            typeRanges = []
        } else {
            typeRanges = items.map {
                let newTotal = total + $0.count
                let result = (type: $0.type, range: Double(total) ..< Double(newTotal))
                total = newTotal
                return result
            }
        }
        totalCount = total
        self.dimension = dimension
    }
        
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                
                if isFullScreen {
                    titleView
                }
                
                Chart(data, id: \.type) { dataItem in
                    SectorMark(angle: .value("Type", dataItem.isAnimated ? dataItem.count : 0),
                               innerRadius: .ratio(0.618),
                               outerRadius: .inset(10),
                               angularInset: 1)
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Type", dataItem.type))
                    .opacity(opacityFor(dataItem))
                }
                .frame(width: dimension, height: dimension)
                .chartAngleSelection(value: $selectedAngle)
                .chartForegroundStyleScale([
                    "Win": .green,
                    "Draw": .blue,
                    "Bye": .orange,
                    "Pending": .gray
                ])
                .chartLegend(isFullScreen ? .visible : .hidden)
                .chartLegend(alignment: .center)
                .onAppear(perform: animateChart)
                .onDisappear(perform: deanimatedChart)
                .chartBackground { p in
                    GeometryReader { g in
                        if let plotFrame = p.plotFrame {
                            let frame = g[plotFrame]
                            overlayView
                                .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
                
                if isFullScreen {
                    Text("Tap to a sector to see more details. There is a total of \(vm.countMatches) matches including byes. The \(vm.poolName) pool is \(percentage) complete.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, isFullScreen ? 20 : 0)
        }
    }
    
    private var titleView: some View {
        VStack(alignment: .leading) {
            Text("Progress")
                .font(.largeTitle.bold())
            Text("\(vm.poolName) \(vm.schedule.description) pool")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func opacityFor(_ dataItem: ChartItem) -> Double {
        guard isFullScreen else { return 1 }
        return dataItem.isAnimated ? (dataItem.type == selectedItem?.type ? 1 : 0.5) : 0
    }
    
    private var percentage: String { "\(Int(Double(vm.countFinishedMatches)/Double(vm.countMatches) * 100.0))%" }
        
    private var overlayView: some View {
        VStack {
            if let s = selectedItem {
                Text(s.count.formatted())
                    .font(.title)
                    .foregroundColor(.primary)
                Text(s.type)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                Text(percentage)
                    .font(isFullScreen ? .title : .headline)
                    .foregroundColor(.primary)
                if isFullScreen {
                    Text("Complete")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var selectedItem: ChartItem? {
        guard isFullScreen else { return nil }
        guard let selectedAngle, let selected = typeRanges.firstIndex(where: { $0.range.contains(selectedAngle) }) else { return nil }
        return data[selected]
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
    
    private func deanimatedChart() {
        guard isAnimated else { return }
        isAnimated = false
        $data.enumerated().forEach { _, element in
            element.wrappedValue.isAnimated = false
        }
    }
}

#Preview {
    struct PreviewableChartFinishView: View {
        struct ViewModelProvider: StatisticsProviding {
            var ranks: [RankInfo] {
                [
                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 1, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
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
            var countMatchByes: Int = 1
            var countMatchDraws: Int = 1
            var countMatchWins: Int = 10
        }
        var body: some View {
            NavigationStack {
                ChartCompleteView(vm: ViewModelProvider(), isFullScreen: true, dimension: 300, isPreview: true)
            }
        }
    }
    return PreviewableChartFinishView()
}

