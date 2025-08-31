import SwiftUI
import SwiftData

struct PoolDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Round.value) private var rounds: [Round]
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    
    private let sourceIDEditPool = "PoolEdit"
    
    let item: Pool
        
    var roundsView: some View {
        let filteredRounds = rounds.filter { $0.pool == item }
        return ForEach(filteredRounds) { round in
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    Text("ROUND \(round.value)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(round.matches.sorted { $0.index < $1.index }) { match in
                        MatchRow(match: match)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 50)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                TabView {
                    roundsView
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .tabItem {
                    Label(item.schedule.description, systemImage: item.schedule.sfSymbolName)
                }
                
                TabView {
                    ScrollView {
                        VStack {
                            Text("Replace Standings")
                                .frame(maxWidth: .infinity, minHeight: 600, alignment: .top)
                        }
                        .padding(.top, 10)
                    }
                }
                .tabViewStyle(.page)
                .tabItem {
                    Label("Standings", systemImage: "tablecells")
                }
                
                TabView {
                    ScrollView {
                        VStack {
                            Text("Replace Charts")
                                .frame(maxWidth: .infinity, minHeight: 600, alignment: .top)
                        }
                        .padding(.top, 10)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .tabItem {
                    Label("Charts", systemImage: "chart.pie")
                }
                
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .navigationTitle(item.name)
            .navigationSubtitle(Text("\(item.rounds.count) rounds, \(item.matchCount) matches, \(item.participants.count) seeds\(item.isHandicap ? " (handicapped)" : "")"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit", systemImage: "square.and.pencil") {
                        showEditPool.toggle()
                    }
                }
                .matchedTransitionSource(id: sourceIDEditPool, in: animationNamespace)
            }
            .sheet(isPresented: $showEditPool) {
                FormPoolView(item: item, onDismiss: { showEditPool = false })
                    .interactiveDismissDisabled(true)
                    .navigationTransition(.zoom(sourceID: sourceIDEditPool, in: animationNamespace))
            }
        }
    }
}

private struct MatchRow: View {
    let match: Match
    @State private var buttonWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let computedButtonWidth = (totalWidth - 56 - 16) / 2
            HStack {
                Button(action: { match.winner = match.left }) {
                    Text(match.leftName)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(match.left == nil)
                .frame(width: computedButtonWidth)
                .contentShape(Rectangle())
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .foregroundStyle(match.leftTextTint)
                .tint(match.leftTint)
                
                Text("\(match.index)")
                    .frame(width: 40, alignment: .center)
                    .multilineTextAlignment(.center)
                
                Button(action: { match.winner = match.right }) {
                    Text(match.rightName)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(match.right == nil)
                .frame(width: computedButtonWidth)
                .contentShape(Rectangle())
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .foregroundStyle(match.rightTextTint)
                .tint(match.rightTint)
            }
            .padding(.horizontal, 8)
            .padding(.top, 1)
        }
        .frame(height: 40)
    }
}

private extension Match {
    var leftName: String { left?.name ?? "BYE" }
    var rightName: String { right?.name ?? "BYE" }

    var leftTextTint: Color { self.winner === self.left ? .white : (self.left == nil ? .gray : .blue) }
    var rightTextTint: Color { self.winner === self.right ? .white : (self.right == nil ? .gray : .blue) }
    
    var leftTint: Color { self.winner === self.left ? .green : .gray.opacity(0.3) }
    var rightTint: Color { self.winner === self.right ? .green : .gray.opacity(0.3) }
}


#Preview {
    let view: some View = {
        let container = try! ModelContainer(for: Pool.self)
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<Pool>()
        let allPool = (try? context.fetch(fetchDescriptor)) ?? []
        for pool in allPool { context.delete(pool) }
        let pool: Pool = .init(
            name: "Preliminaries",
            schedule: .roundRobin,
            timestamp: .now,
            tournament: nil,
            participants: [])
        let m1: Match = .init(index: 1, round: nil, left: .init(name: "David", seed: 1), right: .init(name: "Arthur", seed: 2))
        let m2: Match = .init(index: 2, round: nil, left: .init(name: "Pavel", seed: 3), right: .init(name: "Guidon", seed: 4))
        let r1: Round = .init(value: 1, pool: pool, matches: [m1, m2])
        pool.rounds = [ r1,
                       .init(value: 2, pool: pool, matches: []),
                       .init(value: 3, pool: pool, matches: [])]
        context.insert(pool)
        return PoolDetailView(item: pool)
            .modelContainer(container)
    }()
    view
}

