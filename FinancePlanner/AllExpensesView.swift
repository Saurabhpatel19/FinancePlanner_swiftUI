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

    @State private var expandedYears: Set<Int> = []
   
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                ForEach(expensesByYear, id: \.year) { section in
                    Section {
                        if expandedYears.contains(section.year) {
                            ForEach(section.items) { expense in
                                AllExpenseCard(expense: expense)
                                    .listRowInsets(
                                        EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
                                    )
                            }
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        yearHeader(section: section)
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .navigationTitle("All Expenses")
            .onAppear {
                let currentYear = Calendar.current.component(.year, from: Date())
                expandedYears = Set(expensesByYear
                    .map(\.year)
                    .filter { $0 <= currentYear }   // past & current expanded
                )
            }
        }
    }
            
    private var expensesByYear: [(year: Int, items: [ExpenseModel])] {
        let grouped = Dictionary(grouping: expenses) { $0.year }

        return grouped
            .map { (year: $0.key, items: $0.value.sorted {
                ($0.month, $0.name) < ($1.month, $1.name)
            }) }
            .sorted { $0.year < $1.year }
    }

    private func yearHeader(section: (year: Int, items: [ExpenseModel])) -> some View {

        let total = section.items.reduce(0) { $0 + $1.amount }

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if expandedYears.contains(section.year) {
                    expandedYears.remove(section.year)
                } else {
                    expandedYears.insert(section.year)
                }
            }
        } label: {
            VStack(spacing: 0) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(section.year))
                            .font(.title3.weight(.semibold))     // UIKit-like weight
                            .foregroundColor(.primary)

                        Text("Total: ₹\(Int(total))")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .rotationEffect(
                            .degrees(expandedYears.contains(section.year) ? 0 : -90)
                        )
                        .foregroundColor(.primary)            // subtle color
                        .imageScale(.small)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.blue).opacity(0.7))
                )

//                // Divider for UIKit separation
//                Divider()
//                    .background(Color(.systemGray4))
            }
        }
        .buttonStyle(.plain)
        
    }

}
