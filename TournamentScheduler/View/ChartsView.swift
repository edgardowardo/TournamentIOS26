import SwiftUI
import Charts

struct ChartItem: Identifiable {
    var id: UUID = .init()
    var type: String
    var amount: Int
    var isAnimated: Bool = false
}

struct ChartsView<T: View>: View {
    let vm: StatisticsProviding
    @ViewBuilder var titleSubTitleView: T
    
    
    init(vm: StatisticsProviding, @ViewBuilder titleSubTitleView: () -> T) {
        self.vm = vm
        self.titleSubTitleView = titleSubTitleView()
    }
    
        
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            titleSubTitleView
            
            ChartFinishView(vm: vm)
        }
    }
}

#Preview {
    struct PreviewableChartsView: View {
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
                ChartsView(vm: ViewModelProvider()) {
                    Text("Preview Charts")
                }
            }
        }
    }
    return PreviewableChartsView()
}

