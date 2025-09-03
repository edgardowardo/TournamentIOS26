import Foundation

enum Sport: String, Codable, CaseIterable {
    case athletics
    case badminton
    case baseball
    case basketball
    case boardGames
    case bowling
    case cardGames
    case chess
    case cricket
    case cycling
    case esports
    case football
    case golf
    case handball
    case hockey
    case martialArts
    case racing
    case soccer
    case softball
    case squash
    case swimming
    case tableTennis
    case tennis
    case videoGames
    case volleyball
    case wrestling
    case unknown
    
    var sfSymbolName: String {
        switch self {
        case .athletics: return "figure.run"
        case .badminton: return "figure.badminton"
        case .baseball: return "baseball"
        case .basketball: return "basketball"
        case .boardGames: return "dice"
        case .bowling: return "figure.bowling"
        case .cardGames: return "rectangle.stack"
        case .chess: return "checkerboard.rectangle"
        case .cricket: return "cricket.ball"
        case .cycling: return "bicycle"
        case .esports: return "dpad"
        case .football: return "football"
        case .golf: return "figure.golf"
        case .handball: return "sportscourt"
        case .hockey: return "hockey.puck"
        case .martialArts: return "figure.martial.arts"
        case .racing: return "flag.checkered"
        case .soccer: return "soccerball"
        case .softball: return "figure.softball"
        case .squash: return "sportscourt"
        case .swimming: return "figure.pool.swim"
        case .tableTennis: return "figure.table.tennis"
        case .tennis: return "tennis.racket"
        case .videoGames: return "gamecontroller"
        case .volleyball: return "volleyball"
        case .wrestling: return "figure.wrestling"
        case .unknown: return "trophy"
        }
    }
}
