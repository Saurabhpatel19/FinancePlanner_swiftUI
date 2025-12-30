//
//  HomeExpenseCard.swift
//  FinancePlanner
//
//  Created by Saurabh on 30/12/25.
//

import SwiftUI

struct HomeExpenseCard: View {

    let expense: ExpenseModel
    let isCurrentMonth: Bool
    let onTogglePaid: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            if isCurrentMonth {
                Button(action: onTogglePaid) {
                    Image(systemName: expense.isPaid
                          ? "checkmark.circle.fill"
                          : "circle")
                        .font(.title3)
                        .foregroundColor(
                            expense.isPaid ? .green : .secondary
                        )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.name)
                    .font(.headline)

                Text("\(expense.frequency.rawValue) • \(expense.type.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("₹\(Int(expense.amount))")
                .font(.headline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

