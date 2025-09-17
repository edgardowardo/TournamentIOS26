import SwiftUI

protocol ChartTitleProviding {
    var vm: StatisticsProviding { get }
}

extension ChartTitleProviding {
    func titleView(_ title: String = "Win/Lose") -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle.bold())
            Text("\(vm.poolName) \(vm.schedule.description) pool")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
