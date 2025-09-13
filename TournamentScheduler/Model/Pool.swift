import Foundation
import SwiftData

@Model
final class Pool {
    var name = ""
    var schedule: Schedule
    var seedCount = 0
    var isHandicap = false
    var isSeedsCopyable = true
    var timestamp: Date
    var tournament: Tournament?
    @Relationship(deleteRule: .cascade) var participants: [Participant] = []
    @Relationship(deleteRule: .cascade, inverse: \Round.pool) var rounds: [Round] = []
    @Relationship(deleteRule: .cascade, inverse: \Round.losersPool) var losers: [Round] = []
    
    @Transient var countMatches = 0
    @Transient var countMatchByes = 0
    @Transient var countMatchDraws = 0
    @Transient var countMatchWins = 0
    
    init(name: String = "",
         schedule: Schedule,
         seedCount: Int = 4,
         isHandicap: Bool = false,
         timestamp: Date,
         tournament: Tournament?,
         participants: [Participant]
    ) {
        self.name = name
        self.schedule = schedule
        self.seedCount = seedCount
        self.isHandicap = isHandicap
        self.timestamp = timestamp
        self.tournament = tournament
        self.participants = participants
    }
}

extension Pool {
    var matchCount: Int {
        rounds.reduce(0) { $0 + $1.matches.count } + losers.reduce(0) { $0 + $1.matches.count }
    }
}
