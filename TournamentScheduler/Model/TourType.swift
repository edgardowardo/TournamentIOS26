enum TourType: String, Codable, CaseIterable {
    case roundRobin
    case american
    case singleElimination
    case doubleElimination
}

extension TourType {
    var allowedTeamCounts : [Int] {
        switch self {
        case .american : return (4...32).filter{ ($0 % 4) != 2 }.map { $0 }
        case .roundRobin : fallthrough
        case .singleElimination : fallthrough
        case .doubleElimination : return (2...32).map { $0 }
        }
    }
    
    var sfSymbolName: String {
        switch self {
        case .american : return "globe.americas"
        case .roundRobin : return "r.circle" // bird.circle?
        case .singleElimination : return "1.circle"
        case .doubleElimination : return "2.circle"
        }
    }
    
    var description: String {
        switch self {
        case .american : return "American"
        case .roundRobin : return "Round Robin"
        case .singleElimination : return "Single Elimination"
        case .doubleElimination : return "Double Elimination"
        }
    }
}
