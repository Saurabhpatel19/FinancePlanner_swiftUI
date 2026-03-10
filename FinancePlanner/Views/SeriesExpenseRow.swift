import SwiftUI

struct SeriesExpenseRow: View {
    let summary: SeriesExpenseSummary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.name)
                    .font(.headline)
                    .foregroundColor(ThemeColors.textPrimary)

                HStack(spacing: 6) {
                    Text(summary.frequency.rawValue.capitalized)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(ThemeColors.accent)
                    if let rangeText {
                        Text("• \(rangeText)")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(Int(summary.displayTotal))")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textPrimary)
                if let monthly = summary.monthlyAmount {
                    Text("₹\(Int(monthly)) / month")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
            }
        }
        .padding(14)
        .modernCard(radius: 14)
    }
}

private extension SeriesExpenseRow {
    var rangeText: String? {
        guard let startMonth = summary.startMonth, let startYear = summary.startYear else { return nil }
        let start = monthYearText(month: startMonth, year: startYear)
        guard let endMonth = summary.endMonth, let endYear = summary.endYear else { return "from \(start)" }
        return "\(start) to \(monthYearText(month: endMonth, year: endYear))"
    }

    func monthYearText(month: Int, year: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let date = Calendar.current.date(from: DateComponents(year: year, month: month))!
        return formatter.string(from: date)
    }
}
