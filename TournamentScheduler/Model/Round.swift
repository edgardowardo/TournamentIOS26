import Foundation
import SwiftData

@Model
final class Round {
    var value = 0
    var pool: Pool?
    @Relationship(deleteRule: .cascade, inverse: \Match.round) var matches: [Match] = []
    
    init(value: Int = 0, matches: [Match]) {
        self.value = value
        self.matches = matches
    }
}
