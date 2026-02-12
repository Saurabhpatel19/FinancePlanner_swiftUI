//
//  RootTabView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI

struct RootTabView: View {

    @Environment(\.modelContext) private var context
    @State private var showAddExpense = false
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                YearlyExpenseView()
                    .tag(1)
                    .tabItem {
                        Label("Yearly", systemImage: "calendar")
                    }

                
                // Center plus tab (visual only)
                Color.clear
                    .tag(2)
                    .tabItem {
                        ZStack {
                            // raise the plus slightly above the bar
                            Circle()
                                .fill(ThemeGradients.accentGradient)
                                .frame(width: 54, height: 54)
                                .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                                .offset(y: -10)
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: -10)
                        }
                        .frame(height: 44) // ensures tab item space
                        .accessibilityLabel("Add Expense")
                    }

                AllExpensesView()
                    .tag(3)
                    .tabItem {
                        Label("All", systemImage: "list.bullet.rectangle")
                    }

                // Settings placeholder
                Color.clear
                    .tag(4)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .onChange(of: selectedTab) { old, new in
                if new == 2 { // plus tab tapped
                    // revert to previous tab (default to Home if unknown)
                    selectedTab = (old == 2 ? 0 : old)
                    showAddExpense = true
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            let now = Date()
            let cal = Calendar.current
            let m = cal.component(.month, from: now)
            let y = cal.component(.year, from: now)

            AddEditExpenseView(
                expense: ExpenseModel(
                    name: "",
                    amount: 0,
                    type: .fixed,
                    frequency: .monthly,
                    month: m,
                    year: y
                ),
                actionType: .add,
                context: context
            )
        }
    }
}

