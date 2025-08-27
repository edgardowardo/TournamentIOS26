import Foundation
import SwiftData

@Model
final class Pool {
    var name = ""
    var tourType: TourType
    @Transient var count = 0
    var isHandicap = false
    var isSeedsImportable = true
    var timestamp: Date
    var tournament: Tournament?
    @Relationship(deleteRule: .cascade) var participants: [Participant] = []
    @Relationship(deleteRule: .cascade) var matches: [Match] = []
    
    init(name: String = "",
         tourType: TourType,
         count: Int = 0,
         isHandicap: Bool = false,
         timestamp: Date,
         tournament: Tournament?,
         participants: [Participant],
         matches: [Match]) {
        self.name = name
        self.tourType = tourType
        self.count = count
        self.isHandicap = isHandicap
        self.timestamp = timestamp
        self.tournament = tournament
        self.participants = participants
        self.matches = matches
    }
}
