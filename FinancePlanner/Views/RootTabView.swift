//
//  RootTabView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI

struct RootTabView: View {

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
    }
}


