import Foundation
import SwiftData

@Model
final class Tournament {
    var name = ""
    var tags = ""
    var sport: Sport
    var timestamp: Date
    @Relationship(deleteRule: .cascade, inverse: \Pool.tournament) var pools: [Pool] = []
    
    init(name: String = "", tags: String = "", sport: Sport = .unknown, timestamp: Date = .now, pools: [Pool] = [],) {
        self.name = name
        self.tags = tags
        self.sport = sport
        self.timestamp = timestamp
        self.pools = pools
    }
}

extension Tournament: CustomStringConvertible {
    var description: String {
        name
    }
}
