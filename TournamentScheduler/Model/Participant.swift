import SwiftData

@Model
final class Participant {
    var name: String
    var isHandicapped: Bool = false
    var handicapPoints: Int = 0
    var seed: Int = 0
    
    init(name: String, isHandicapped: Bool, handicapPoints: Int, seed: Int) {
        self.name = name
        self.isHandicapped = isHandicapped
        self.handicapPoints = handicapPoints
        self.seed = seed
    }
}
