//
//  Item.swift
//  TournamentScheduler
//
//  Created by EDGARDO AGNO on 21/08/2025.
//

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

enum Sport: String, Codable, CaseIterable {
    case badminton
    case basketball
    case football
    case soccer
    case volleyball
    case unknown
}

