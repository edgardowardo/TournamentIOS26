import SwiftUI
import SwiftData

struct StandingsView: View {
    let vm: ViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                
                // headers
                GridRow {
                    Text("RANK")
                    Text("NAME")
                    Text("P")
                    Text("W")
                    Text("L")
                    Text("D")
                }
                
                // rows
                ForEach(vm.standings) { rowVM in
                    GridRow {
                        Text("\(rowVM.rank)")
                        Text(rowVM.name)
                        Text("\(rowVM.countPlayed)")
                        Text("\(rowVM.countWins)")
                        Text("\(rowVM.countLost)")
                        Text("\(rowVM.countDrawn)")
                    }
                }
            }
        }
    }
}

