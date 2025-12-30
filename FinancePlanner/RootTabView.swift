//
//  RootTabView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI
import SwiftData

struct RootTabView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var didMigrate = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            YearlyExpenseView()
                .tabItem {
                    Label("Yearly", systemImage: "calendar")
                }

            AllExpensesView()
                .tabItem {
                    Label("All", systemImage: "list.bullet.rectangle")
                }
        }
//        .task {
//            // Runs once when view appears
//            if !didMigrate {
//                ExpenseMigration.migratePaidState(context: modelContext)
//                didMigrate = true
//            }
//        }
    }
}

