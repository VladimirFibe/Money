//
//  MoneyApp.swift
//  Money
//
//  Created by Vladimir Fibe on 04.01.2022.
//

import SwiftUI

@main
struct MoneyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
