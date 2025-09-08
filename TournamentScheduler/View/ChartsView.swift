import SwiftUI
import Charts

struct ChartItem: Identifiable {
    var id: UUID = .init()
    var type: String
    var count: Int
    var isAnimated: Bool = false
}

struct ChartsView<T: View>: View {
    let vm: StatisticsProviding
    private let isPreview: Bool
    @ViewBuilder var titleSubTitleView: T
        
    init(vm: StatisticsProviding, isPreview: Bool = false, @ViewBuilder titleSubTitleView: () -> T) {
        self.vm = vm
        self.isPreview = isPreview
        self.titleSubTitleView = titleSubTitleView()
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                
                titleSubTitleView

                Text("Completed Matches")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                GroupBox {
                    ChartCompleteMatchesView(vm: vm, isPreview: isPreview)
                        .frame(height: 275)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Win Lose Draw")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                GroupBox {
                    ChartWinsView(vm: vm, countPrefix: 3, isShowAll: true)
                        .frame(height: chartHeight)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var chartHeight: CGFloat {
        let barHeight: CGFloat = 16
        let barSpacing: CGFloat = 20
        let minChartHeight: CGFloat = 120
        let height = max(minChartHeight, CGFloat(vm.ranks.count) * (barHeight + barSpacing) + 60)
        return height
    }
}

#Preview {
    struct PreviewableChartsView: View {
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
                    
                    
                    .init(oldrank: 2, rank: 1, name: "Alice", countParticipated: 5, countPlayed: 5, countWins: 4, countLost: 1, countDrawn: 0, countBye: 0, pointsFor: 3, pointsAgainst: 0, pointsDifference: 5),
                    .init(oldrank: 1, rank: 2, name: "Bob", countParticipated: 5, countPlayed: 5, countWins: 3, countLost: 1, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 3),
                    .init(oldrank: 3, rank: 3, name: "Carol", countParticipated: 5, countPlayed: 5, countWins: 2, countLost: 2, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 2),
                    .init(oldrank: 4, rank: 4, name: "Dave", countParticipated: 5, countPlayed: 5, countWins: 1, countLost: 3, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 1),
                    .init(oldrank: 5, rank: 5, name: "Eve", countParticipated: 5, countPlayed: 5, countWins: 0, countLost: 4, countDrawn: 1, countBye: 1, pointsFor: 0, pointsAgainst: 0, pointsDifference: 0)
                ]
            }
            let schedule: Schedule = .roundRobin
            let nOverP: Int = 5
            var countMatches: Int = 16
            var countMatchByes: Int = 4
            var countMatchDraws: Int = 4
            var countMatchWins: Int = 31
        }
        var body: some View {
            NavigationStack {
                ChartsView(vm: ViewModelProvider(), isPreview: true) {
                    Text("Preview Charts")
                }
            }
        }
    }
    return PreviewableChartsView()
}

