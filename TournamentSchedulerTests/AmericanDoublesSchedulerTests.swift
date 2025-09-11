import Testing
@testable import TournamentScheduler
internal import Foundation

@Suite("American Doubles scheduler across allowed seed counts")
struct AmericanDoublesSchedulerTests {

    // MARK: - Helpers
    @MainActor
    private func makeParticipants(_ count: Int) -> [Participant] {
        (1...count).map { Participant(name: "Seed \($0)", seed: $0) }
    }

    @MainActor
    private func makePool(seeds: Int) -> Pool {
        let participants = makeParticipants(seeds)
        let pool = Pool(name: "Test Pool", schedule: .americanDoubles, seedCount: seeds, isHandicap: false, timestamp: .now, tournament: nil, participants: participants)
        ScheduleBuilder(pool: pool).schedule()
        return pool
    }

    // MARK: - Assertions
    private func assertDoublesIntegrity(_ pool: Pool, expectedParticipants: Int, file: StaticString = #file, line: UInt = #line) {
        // For odd counts, a single bye placeholder is added per round; even counts should have none
        let isOdd = !expectedParticipants.isMultiple(of: 2)
        #expect(!pool.rounds.isEmpty, "Rounds should be generated")
        for round in pool.rounds {
            #expect(!round.matches.isEmpty, "Each round should have matches")
            for match in round.matches {
                // In American doubles, left/right must exist unless bye propagates; if a team is nil it should be treated as a bye
                let leftHasPair = (match.left != nil && match.doublesInfo?.leftParticipant2 != nil)
                let rightHasPair = (match.right != nil && match.doublesInfo?.rightParticipant2 != nil)
                if isOdd {
                    // With an odd participant count, byes can occur
                    #expect(leftHasPair || rightHasPair, "At least one side should be a full pair per match")
                } else {
                    #expect(leftHasPair && rightHasPair, "Both sides should be full doubles pairs when even")
                }
            }
        }
    }

    // For American style with N players, typical rotation produces up to N-1 rounds when even; with odd, up to N rounds due to inserted bye.
    private func expectedMaxRounds(for participants: Int) -> Int {
        let evenCount = participants.isMultiple(of: 2)
        return evenCount ? participants - 1 : participants
    }

    private func matchesPerRound(for count: Int) -> Int {
        // Effective players excludes the bye if odd
        let effective = count.isMultiple(of: 2) ? count : count - 1
        return effective / 4
    }

    // MARK: - Tests

    @Test("American Doubles across allowed seed counts", arguments: Schedule.americanDoubles.allowedSeedCounts)
    @MainActor
    func testAmericanDoublesParameterized(seedCount: Int) async throws {
        let pool = makePool(seeds: seedCount)
        #expect(1...expectedMaxRounds(for: seedCount) ~= pool.rounds.count)
        let expectedPerRound = matchesPerRound(for: seedCount)
        for r in pool.rounds {
            #expect(r.matches.count == expectedPerRound)
        }
        assertDoublesIntegrity(pool, expectedParticipants: seedCount)
    }

    @Test("Excluded seed counts 6, 10, and 14 are not allowed for American in UI choices")
    @MainActor
    func testExcludedSeedCounts() async throws {
        // Schedule.allowedSeedCounts excludes counts where count % 4 == 2, e.g., 6, 10, 14.
        // We validate the policy here; the scheduler itself will still attempt to schedule if forced.
        let allowed = Schedule.americanDoubles.allowedSeedCounts
        #expect(!allowed.contains(6), "6 should be excluded from American allowed seed counts")
        #expect(!allowed.contains(10), "10 should be excluded from American allowed seed counts")
        #expect(!allowed.contains(14), "14 should be excluded from American allowed seed counts")
    }
}
