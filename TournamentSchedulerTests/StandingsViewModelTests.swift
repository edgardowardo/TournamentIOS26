import Testing
@testable import TournamentScheduler
internal import Foundation

@Suite("StandingsViewModel ranking logic")
struct StandingsViewModelTests {
    @Test("Ranks by number of wins")
    @MainActor
    func testRanksByWins() async throws {
        let alice = Participant(name: "Alice", seed: 1)
        let bob = Participant(name: "Bob", seed: 2)
        let carol = Participant(name: "Carol", seed: 3)
        // Alice beats Bob, Bob beats Carol, Alice beats Carol
        let m1 = Match(index: 1, round: nil, winner: alice, left: alice, right: bob, leftScore: 5, rightScore: 3)
        let m2 = Match(index: 2, round: nil, winner: bob, left: bob, right: carol, leftScore: 4, rightScore: 6)
        let m3 = Match(index: 3, round: nil, winner: alice, left: alice, right: carol, leftScore: 8, rightScore: 5)
        let round = Round(value: 1, pool: nil, matches: [m1, m2, m3])
        let pool = Pool(name: "Test", schedule: .roundRobin, seedCount: 3, isHandicap: false, timestamp: .now, tournament: nil, participants: [alice, bob, carol])
        pool.rounds = [round]
        let vm = StandingsView.ViewModel(pool: pool)
        let namesByRank = vm.standings.map { $0.name }
        #expect(namesByRank == ["Alice", "Bob", "Carol"], "Alice (2 wins) > Bob (1 win) > Carol (0 wins)")
    }

    @Test("Ranks by draws if wins are equal")
    @MainActor
    func testRanksByDrawsIfEqualWins() async throws {
        let alice = Participant(name: "Alice", seed: 1)
        let bob = Participant(name: "Bob", seed: 2)
        // Both draw
        let m1 = Match(index: 1, round: nil, winner: nil, left: alice, right: bob, isDraw: true, leftScore: 3, rightScore: 3)
        let round = Round(value: 1, pool: nil, matches: [m1])
        let pool = Pool(name: "Test", schedule: .roundRobin, seedCount: 2, isHandicap: false, timestamp: .now, tournament: nil, participants: [alice, bob])
        pool.rounds = [round]
        let vm = StandingsView.ViewModel(pool: pool)
        let namesByRank = vm.standings.map { $0.name }
        #expect(Set(namesByRank) == Set(["Alice", "Bob"]), "Both have 0 wins, 1 draw: tied, any order")
    }
    
    @Test("Ranks by draws where wins are equal and a clear winner exists")
    @MainActor
    func testRanksByDrawsWithClearWinner() async throws {
        let alice = Participant(name: "Alice", seed: 1)
        let bob = Participant(name: "Bob", seed: 2)
        // Alice wins one, Bob wins one, but Alice has more draws
        let m1 = Match(index: 1, round: nil, winner: alice, left: alice, right: bob, leftScore: 5, rightScore: 3)
        let m2 = Match(index: 2, round: nil, winner: bob, left: bob, right: alice, leftScore: 4, rightScore: 6)
        let m3 = Match(index: 3, round: nil, winner: nil, left: alice, right: bob, isDraw: true, leftScore: 2, rightScore: 2)
        let m4 = Match(index: 4, round: nil, winner: nil, left: alice, right: bob, isDraw: true, leftScore: 1, rightScore: 1)
        let m5 = Match(index: 5, round: nil, winner: nil, left: bob, right: alice, isDraw: true, leftScore: 3, rightScore: 3)
        // Alice: 1 win, 3 draws; Bob: 1 win, 2 draws
        let round = Round(value: 1, pool: nil, matches: [m1, m2, m3, m4, m5])
        let pool = Pool(name: "Test", schedule: .roundRobin, seedCount: 2, isHandicap: false, timestamp: .now, tournament: nil, participants: [alice, bob])
        pool.rounds = [round]
        let vm = StandingsView.ViewModel(pool: pool)
        let namesByRank = vm.standings.map { $0.name }
        #expect(namesByRank.first == "Alice", "Alice has more draws and should rank first when wins are equal")
    }
    
    

    @Test("Ranks by points difference if wins and draws are equal")
    @MainActor
    func testRanksByPointsDifferenceIfEqualWinsAndDraws() async throws {
        let alice = Participant(name: "Alice", seed: 1)
        let bob = Participant(name: "Bob", seed: 2)
        // Both draw, but Alice scores more points in another match
        let m1 = Match(index: 1, round: nil, winner: nil, left: alice, right: bob, isDraw: true, leftScore: 4, rightScore: 4)
        let m2 = Match(index: 2, round: nil, winner: nil, left: alice, right: bob, isDraw: true, leftScore: 10, rightScore: 7)
        let round = Round(value: 1, pool: nil, matches: [m1, m2])
        let pool = Pool(name: "Test", schedule: .roundRobin, seedCount: 2, isHandicap: false, timestamp: .now, tournament: nil, participants: [alice, bob])
        pool.rounds = [round]
        let vm = StandingsView.ViewModel(pool: pool)
        let namesByRank = vm.standings.map { $0.name }
        #expect(namesByRank.first == "Alice", "Alice has higher points difference and should rank first")
    }
}

