import SwiftUI
import SwiftData

struct PoolDetailView: View {
    @Namespace private var animationNamespace
    @State private var showEditPool: Bool = false
    @State private var containerWidth: CGFloat = 0
    @State private var filterRound = -1
    @State private var selectedTab: Int = 0
    
    private let sourceIDEditPool = "PoolEdit"
    
    let item: Pool
        
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { containerWidth = proxy.size.width }
                                .onChange(of: proxy.size.width) { _, newValue in
                                    containerWidth = newValue
                                }
                        }
                    )
                
                TabView(selection: $selectedTab) {
                    Tab(item.schedule.description, systemImage: item.schedule.sfSymbolName, value: 0) {
                        RoundsView(
                            rounds: item.rounds.sorted { $0.value < $1.value },
                            availableWidth: containerWidth,
                            filterRound: filterRound)
                    }
                    
                    Tab("Standings", systemImage: "tablecells", value: 10) {
                        ScrollView {
                            VStack {
                                Text("Replace Standings")
                                    .frame(maxWidth: .infinity, minHeight: 600, alignment: .top)
                            }
                            .padding(.top, 10)
                        }
                    }
                                        
                    Tab("Charts", systemImage: "chart.pie", value : 20) {
                        ScrollView {
                            VStack {
                                Text("Replace Charts")
                                    .frame(maxWidth: .infinity, minHeight: 600, alignment: .top)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory {
                    if selectedTab == 0 {
                        Menu {
                            ForEach(item.rounds.sorted { $0.value > $1.value }, id: \.self) { r in
                                Button("\(r.value)") { filterRound = r.value }
                            }
                            Button("All Rounds") { filterRound = -1 }
                        } label: {
                            Text(filterRound == -1 ? "All Rounds" : "Round \(filterRound)")
                                .foregroundStyle(.blue)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            
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

private struct RoundsView: View {
    let rounds: [Round]
    let availableWidth: CGFloat
    let filterRound: Int

    var body: some View {
        ScrollView {
            ForEach(rounds.filter { filterRound == -1 || $0.value == filterRound }) { round in
                LazyVStack(alignment: .center, spacing: 10) {
                    Text("ROUND \(round.value)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(round.matches.sorted { $0.index < $1.index }) { match in
                        MatchRow(match: match, availableWidth: availableWidth)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

private struct MatchRow: View {
    let match: Match
    let availableWidth: CGFloat
    
    var body: some View {
        HStack {
            Button(action: { match.winner = match.left }) {
                Text(match.leftName)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(match.left == nil)
            .frame(width: max(0, (availableWidth - 56 - 16) / 2))
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
            .frame(width: max(0, (availableWidth - 56 - 16) / 2))
            .contentShape(Rectangle())
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .foregroundStyle(match.rightTextTint)
            .tint(match.rightTint)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .center)
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
