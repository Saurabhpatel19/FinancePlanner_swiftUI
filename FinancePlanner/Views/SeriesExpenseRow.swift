//
//  SeriesExpenseRow.swift
//  FinancePlanner
//
//  Created by Saurabh on 05/01/26.
//


import SwiftUI

struct SeriesExpenseRow: View {

    let summary: SeriesExpenseSummary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {

                // Expense name
                Text(summary.name)
                    .font(.headline)

                // Meta info
                HStack(spacing: 6) {
                    Text(summary.frequency.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let rangeText {
                        Text("• \(rangeText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                
                // Amount
                Text("₹\(Int(summary.displayTotal))")
                    .font(.headline)
                
                if let monthly = summary.monthlyAmount {
                    Text("₹\(Int(monthly)) / month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }
}

private extension SeriesExpenseRow {

    var rangeText: String? {
        guard
            let startMonth = summary.startMonth,
            let startYear = summary.startYear
        else { return nil }

        let start = monthYearText(month: startMonth, year: startYear)

        guard
            let endMonth = summary.endMonth,
            let endYear = summary.endYear
        else {
            return "from \(start)"
        }

        let end = monthYearText(month: endMonth, year: endYear)
        return "\(start) → \(end)"
    }

    func monthYearText(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        let date = Calendar.current.date(
            from: DateComponents(year: year, month: month)
        )!

        return formatter.string(from: date)
    }
}
