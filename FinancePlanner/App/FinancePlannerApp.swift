//
//  FinancePlannerApp.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//

import SwiftUI
import SwiftData

@main
struct FinancePlannerApp: App {
    @StateObject private var themeStore = ThemeStore.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(themeStore)
                .preferredColorScheme(themeStore.isDarkMode ? .dark : .light)
                .id(themeStore.refreshID)
        }
        .modelContainer(for: [
            ExpenseModel.self
        ])
    }
}





