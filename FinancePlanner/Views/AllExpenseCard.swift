import SwiftUI

struct AllExpenseCard: View {
    let expense: ExpenseModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(expense.name)
                    .font(.headline)
                    .foregroundColor(ThemeColors.textPrimary)
                Spacer()
                Text("₹\(Int(expense.amount))")
                    .font(.headline.weight(.bold))
                    .foregroundColor(ThemeColors.textPrimary)
            }

            infoRow(title: "Series", value: shortSeriesId)
            infoRow(title: "Month", value: "\(monthText) \(yearText)")
            HStack {
                let category = expense.category ?? .other
                Text("Category")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
                Spacer()
                Label(category.displayTitle, systemImage: category.systemImage)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textPrimary)
            }
            infoRow(title: "Range", value: rangeText)

            if let paidDate = expense.paymentDate {
                Divider().overlay(ThemeColors.cardBorder)
                HStack {
                    Label("Paid", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(ThemeColors.positive)
                    Spacer()
                    Text(formattedDate(paidDate))
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
            }
        }
        .padding(16)
        .modernCard()
    }
}

private extension AllExpenseCard {
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(ThemeColors.textPrimary)
        }
    }

    var shortSeriesId: String {
        String(expense.seriesId.uuidString.prefix(8)).uppercased()
    }

    var monthText: String { DateFormatter().monthSymbols[expense.month - 1] }
    var yearText: String { String(expense.year) }

    var rangeText: String {
        guard let startYear = expense.startYear else { return "One-time" }
        let startMonth = expense.startMonth ?? expense.month
        let endMonth = expense.endMonth ?? expense.month
        let endYear = expense.endYear ?? expense.year
        return "\(DateFormatter().shortMonthSymbols[startMonth - 1]) \(startYear) - \(DateFormatter().shortMonthSymbols[endMonth - 1]) \(endYear)"
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
