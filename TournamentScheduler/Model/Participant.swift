import SwiftData

@Model
final class Participant {
    var name: String
    var isHandicapped: Bool = false
    var handicapPoints: Int = 0
    var seed: Int = 0
    
    init(name: String,
         isHandicapped: Bool = false,
         handicapPoints: Int = 0,
         seed: Int) {
        self.name = name
        self.isHandicapped = isHandicapped
        self.handicapPoints = handicapPoints
        self.seed = seed
    }
}

extension Participant: CustomStringConvertible {
    var description: String {
        "\(seed). \(name)"
    }
}
