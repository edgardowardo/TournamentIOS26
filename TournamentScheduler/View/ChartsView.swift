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
            VStack(alignment: .leading, spacing: 30) {
                titleSubTitleView
                completionView
                topPerformersView
                bottomPerformersView
            }
            .padding(.horizontal)
        }
    }
    
    private var bottomPerformersView: some View {
        GroupBox("Bottom Performers") {
            NavigationLink {
                ChartRanksContainerView(vm: vm)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on the number of losses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        ChartRanksView(vm: vm, count: 3, column: .lose, isShowAll: false)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var topPerformersView: some View {
        GroupBox("Top Performers") {
            NavigationLink {
                ChartRanksContainerView(vm: vm)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on the number of wins")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        ChartRanksView(vm: vm, count: 3, column: .win, isShowAll: false)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var completionView: some View {
        GroupBox {
            NavigationLink {
                ChartCompleteView(vm: vm, isFullScreen: true, isPreview: isPreview)
                    .navigationTitle("Completion")
            } label: {
                HStack {
                    Text("This pool has completed \(vm.countFinishedMatches) out of \(vm.countMatches) matches. That's \(Int(Double(vm.countFinishedMatches)/Double(vm.countMatches) * 100.0))% of all matches.")
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    ChartCompleteView(vm: vm, isFullScreen: false, isPreview: isPreview)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
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
            let poolName: String = "Preliminaries"
            var countMatches: Int = 16
            var countMatchByes: Int = 4
            var countMatchDraws: Int = 4
            var countMatchWins: Int = 3
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
