//
//  SelectNavBarApp.swift
//  SelectNavBar
//
//  Created by Yuki Sasaki on 2025/08/30.
//

import SwiftUI

@main
struct SelectNavBarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
