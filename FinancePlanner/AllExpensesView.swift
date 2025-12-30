//
//  AllExpensesView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI
import SwiftData

struct AllExpensesView: View {

    // MARK: - Data
    @Query(sort: [
        SortDescriptor(\ExpenseModel.year, order: .forward),
        SortDescriptor(\ExpenseModel.month, order: .forward)
    ])
    private var expenses: [ExpenseModel]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(expenses) { expense in
                        AllExpenseCard(expense: expense)
                    }
                }
                .padding()
            }
            .navigationTitle("All Expenses")
        }
    }
}
