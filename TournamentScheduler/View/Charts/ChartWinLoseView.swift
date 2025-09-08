import SwiftUI
import Charts


struct PlayerResult: Identifiable {
    let id = UUID()
    let name: String
    let wins: Int
    let lose: Int
}

struct ChartWinLoseView: View {
    let players: [PlayerResult] = [
        .init(name: "Alice", wins: 8, lose: 3),
        .init(name: "Bob", wins: 5, lose: 6),
        .init(name: "Charlie", wins: 10, lose: 2),
        .init(name: "Diana", wins: 3, lose: 9)
    ]

    var body: some View {
        Chart {
            ForEach(players) { player in
                // Wins (positive values → right side)
                BarMark(
                    x: .value("Win", player.wins),
                    y: .value("Player", player.name)
                )
                .annotation(position: .overlay) {
                    Text(player.wins.formatted())
                        .font(Font.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(by: .value("Result", "Win"))
                
                // Losses (negative values → left side)
                BarMark(
                    x: .value("Lose", -player.lose),
                    y: .value("Player", player.name)
                )
                .annotation(position: .overlay) {
                    Text(player.lose.formatted())
                        .font(Font.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(by: .value("Result", "Lose"))
                
            }
        }
        .chartXAxis {
            AxisMarks(values: Array(stride(from: -10, through: 10, by: 2))) { value in
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        Text("\(abs(intVal))") // Show positive labels on both sides
                    }
                }
            }
        }
        .frame(height: 300)
        .padding()
        .chartLegend(position: .bottom)
        .chartForegroundStyleScale([
            "Win": .green,
            "Lose": .red
        ])
    }
}

#Preview {
    ChartWinLoseView()
}
