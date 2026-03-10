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
                    Image(systemName: expense.isPaid ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(expense.isPaid ? ThemeColors.positive : ThemeColors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(expense.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimary)

                HStack(spacing: 6) {
                    badge(expense.frequency.displayTitle, tint: ThemeColors.accent)
                    metaText
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("₹\(Int(expense.amount))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimary)
                if expense.isPaid {
                    Text("Paid")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(ThemeColors.positive)
                }
            }
        }
        .padding(14)
        .modernCard(radius: 14)
    }

    private func badge(_ title: String, tint: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundColor(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }

    private var metaText: some View {
        let category = expense.category ?? .other
        return Text(metaLine(for: category))
            .font(.caption2)
            .foregroundColor(ThemeColors.textSecondary)
            .lineLimit(1)
    }

    private func metaLine(for category: ExpenseCategory) -> String {
        var parts: [String] = [expense.type.displayTitle, category.displayTitle]
        if let dueDay = expense.dueDay {
            parts.append("Due \(dueDay)")
        }
        return parts.joined(separator: " • ")
    }
}
