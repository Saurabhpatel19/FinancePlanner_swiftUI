//
//  ExpenseCard.swift
//  FinancePlanner
//
//  Created by Saurabh on 30/12/25.
//

import SwiftUI

struct ExpenseCard: View {

    let expense: ExpenseModel
    var selectedYear: Int?
    var isCurrentMonth: Bool = false
    let onTogglePaid: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            if isCurrentMonth || selectedYear != nil {
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
                .scaleEffect(1.4)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.name)
                    .font(.headline)

                if let dueDay = expense.dueDay {
                    let monthYearTitle = monthYearTitle(month: expense.month, year: expense.year)
                    Text("Due: \(dueDay) \(monthYearTitle)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("₹\(Int(expense.amount))")
                .font(.headline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.white))
        )
        .shadow(
            color: Color.black.opacity(0.2),
            radius: 8,
            y: 4
        )
    }
    
    func monthYearTitle(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        let date = Calendar.current.date(
            from: DateComponents(year: year, month: month)
        )!

        return formatter.string(from: date)
    }
}

