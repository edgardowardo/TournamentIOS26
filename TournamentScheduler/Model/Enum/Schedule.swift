enum Schedule: String, Codable, CaseIterable {
    case roundRobin
    case americanDoubles
    case singleElimination
    case doubleElimination
}

extension Schedule {
    var allowedSeedCounts : [Int] {
        switch self {
        case .americanDoubles : return (4...32).filter{ ($0 % 4) != 2 }.map { $0 }
        case .roundRobin : return (2...32).map { $0 }
        case .singleElimination : fallthrough
        case .doubleElimination : return (2...64).map { $0 }
        }
    }
    
    var sfSymbolName: String {
        switch self {
        case .americanDoubles : return "globe.americas"
        case .roundRobin : return "r.circle" // bird.circle?
        case .singleElimination : return "1.circle"
        case .doubleElimination : return "2.circle"
        }
    }
    
    var description: String {
        switch self {
        case .americanDoubles : return "American Doubles"
        case .roundRobin : return "Round Robin"
        case .singleElimination : return "Single Elimination"
        case .doubleElimination : return "Double Elimination"
        }
    }
    
    var showNoverPHeader: Bool {
        self == .americanDoubles || self == .roundRobin
    }
    
    var isWinnerPromotable: Bool {
        [.singleElimination, .doubleElimination].contains(self)
    }
}
