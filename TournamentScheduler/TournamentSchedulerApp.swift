//
//  TournamentSchedulerApp.swift
//  TournamentScheduler
//
//  Created by EDGARDO AGNO on 21/08/2025.
//

import SwiftUI
import SwiftData

@main
struct TournamentSchedulerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Tournament.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
