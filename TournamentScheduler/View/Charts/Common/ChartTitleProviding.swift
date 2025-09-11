import SwiftUI

protocol ChartTitleProviding {
    var vm: StatisticsProviding { get }
}

extension ChartTitleProviding {
    var titleView: some View {
        VStack(alignment: .leading) {
            Text("Winners & Losers")
                .font(.largeTitle.bold())
            Text("\(vm.poolName) \(vm.schedule.description) pool")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
