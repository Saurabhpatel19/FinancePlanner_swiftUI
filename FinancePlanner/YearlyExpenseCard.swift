//
//  YearlyExpenseCard.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI

struct YearlyExpenseCard: View {

    let expense: ExpenseModel
    let year: Int

    var body: some View {
        let isPaid = expense.isPaid

        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(expense.name)
                    .font(.headline)

                Text("₹\(Int(expense.amount)) / year")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                expense.togglePaid(year: year)
            } label: {
                Image(systemName: isPaid
                      ? "checkmark.circle.fill"
                      : "circle")
                    .foregroundColor(isPaid ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }
}


