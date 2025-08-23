import Foundation
import SwiftData

@Model
final class Tournament {
    var timestamp: Date
    var name = "Tournament Name"
    var tags = ""
    var sport: Sport
    
    init(timestamp: Date, sport: Sport = .unknown) {
        self.timestamp = timestamp
        self.sport = sport
    }
}
