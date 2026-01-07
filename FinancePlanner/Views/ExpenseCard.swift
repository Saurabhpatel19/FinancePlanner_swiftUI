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
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 12) {

                if isCurrentMonth || selectedYear != nil {
                    Button(action: onTogglePaid) {
                        Image(systemName: expense.isPaid
                              ? "checkmark.circle.fill"
                              : "circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(
                                expense.isPaid ? ThemeColors.positive : ThemeColors.textSecondary
                            )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(expense.name)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        if let dueDay = expense.dueDay {
                            let monthName = getMonthName(month: expense.month)
                            Text("Due: \(dueDay) \(monthName)")
                                .font(.caption2)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                    }

                    HStack(spacing: 8) {
                        // Frequency badge
                        Text(expense.frequency.displayTitle)
                            .font(.caption2)
                            .foregroundColor(ThemeColors.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(ThemeColors.accent.opacity(0.1))
                            .cornerRadius(4)
                        
                        // Type badge
                        Text(expense.type.displayTitle)
                            .font(.caption2)
                            .foregroundColor(ThemeColors.accentPurple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(ThemeColors.accentPurple.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(Int(expense.amount))")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    if expense.isPaid {
                        Text("Paid")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.positive)
                    }
                }
            }
            .padding(14)
        }
        .background(ThemeColors.cardBackground)
        .border(ThemeColors.cardBorder, width: 1)
        .cornerRadius(12)
    }
    
    func getMonthName(month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(year: 2024, month: month, day: 1))!
        return formatter.string(from: date)
    }
}

