import Foundation
import SwiftData

@Model
final class Pool {
    var name = ""
    var tourType: TourType
    var count = 0
    var isHandicap = false
    var timestamp: Date
    var participants : [Participant] = []
    var matches: [Match] = []
    
    init(name: String = "", tourType: TourType, count: Int = 0, isHandicap: Bool = false, timestamp: Date, participants: [Participant], matches: [Match]) {
        self.name = name
        self.tourType = tourType
        self.count = count
        self.isHandicap = isHandicap
        self.timestamp = timestamp
        self.participants = participants
        self.matches = matches
    }
}
