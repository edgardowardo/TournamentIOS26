import Foundation
import SwiftData

@Model
final class Tournament {
    var name = ""
    var tags = ""
    var sport: Sport
    var pools: [Pool] = []
    var timestamp: Date
    
    init(name: String = "", tags: String = "", sport: Sport = .unknown, pools: [Pool] = [], timestamp: Date = .now) {
        self.name = name
        self.tags = tags
        self.sport = sport
        self.pools = pools
        self.timestamp = timestamp
    }
}


