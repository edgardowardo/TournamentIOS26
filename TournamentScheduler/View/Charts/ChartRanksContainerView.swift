import SwiftUI
import Charts

extension ChartRanksContainerView {
    enum TabType {
        case winlose
        case drawIncluded
        case points
    }
}

struct ChartRanksContainerView: View {
    
    let vm: StatisticsProviding
    
    @State private var isShowAllRow: Bool = false
    @State private var selectedTab: TabType = .winlose
        
    var body: some View {
        TabView(selection: $selectedTab.animation(.bouncy)) {
            Tab("Win/Lose", systemImage: "flag.filled.and.flag.crossed", value: .winlose ) {
                ScrollView {
                    ChartWinLoseView(vm: vm, isShowAllRow: isShowAllRow)
                        .padding(.horizontal)
                }
            }
            
            Tab("All", systemImage: "person.crop.rectangle.stack", value: .drawIncluded ) {
                ScrollView {
                    ChartRanksView(vm: vm, count: vm.ranks.count, column: .all, isShowAllRow: isShowAllRow)
                        .padding(.horizontal)
                }
            }
            
            Tab("Score", systemImage: "numbers.rectangle", value: .points ) {
                ScrollView {
                    ChartPointsView(vm: vm, isShowAllRow: isShowAllRow)
                        .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Winners & Losers")
        .navigationSubtitle("\(vm.schedule.rawValue.capitalized) \(vm.poolName) Pool")
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            Toggle("Show not played", isOn: $isShowAllRow.animation(.bouncy))
                .toggleStyle(.switch)
                .padding()

        }
    }
}

#Preview {
    struct PreviewableChartRanksContainerView: View {
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
                ChartRanksContainerView(vm: ViewModelProvider())
            }
        }
    }
    return PreviewableChartRanksContainerView()
}
