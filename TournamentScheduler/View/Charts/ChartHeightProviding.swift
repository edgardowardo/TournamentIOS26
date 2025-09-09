import Foundation

protocol ChartHeightProviding {}

extension ChartHeightProviding {
     func chartHeightFor(_ count: Int) -> CGFloat {
        let barHeight: CGFloat = 16
        let barSpacing: CGFloat = count > 3 ? 40 : 20 // 3 is for the preview, for bigger view we want double
        let minChartHeight: CGFloat = 120
        let height = max(minChartHeight, CGFloat(count) * (barHeight + barSpacing) + 60)
        return height
    }
}
