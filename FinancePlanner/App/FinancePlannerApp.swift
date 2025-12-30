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

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [
            ExpenseModel.self,
            MonthModel.self
        ])
    }
}





