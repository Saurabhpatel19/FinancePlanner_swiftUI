//
//  AllExpenseCard.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI

struct AllExpenseCard: View {

    let expense: ExpenseModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // MARK: - Section 1: Expense Info
            VStack(alignment: .leading, spacing: 10) {

                // Name + Amount
                HStack {
                    Text(expense.name)
                        .font(.headline)

                    Spacer()

                    Text("₹\(Int(expense.amount))")
                        .font(.headline)
                }

                infoRow(title: "Serial ID", value: shortSeriesId)
                infoRow(title: "Month-Year", value: monthText + "-" + yearText)
                infoRow(title: "Start Month-Year", value: startMonthText + "-" + startYearText)
                infoRow(title: "End Month-Year", value: endMonthText + "-" + endYearText)

            }

            // MARK: - Section 2: Payment Info (Only if paid)
            if let paidDate = expense.paidDate {
                Divider()

                VStack(alignment: .leading, spacing: 8) {

                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        Text("Paid")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.green)
                    }

                    infoRow(
                        title: "Paid On",
                        value: formattedDate(paidDate)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}


private extension AllExpenseCard {

    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
        }
    }

    var shortSeriesId: String {
        String(expense.seriesId.uuidString.prefix(8)).uppercased()
    }

    var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.monthSymbols[expense.month - 1]
    }

    var yearText: String {
        String(expense.year)
    }

    var startMonthText: String {
        if let startMonth = expense.startMonth {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            return formatter.monthSymbols[startMonth - 1]
        }
        return ""
    }

    var startYearText: String {
        if let startYear = expense.startYear {
            return String(startYear)
        }
        return ""
    }
    
    var endMonthText: String {
        if let startMonth = expense.endMonth {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            return formatter.monthSymbols[startMonth - 1]
        }
        return ""
    }

    var endYearText: String {
        if let startYear = expense.endYear {
            return String(startYear)
        }
        return ""
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

