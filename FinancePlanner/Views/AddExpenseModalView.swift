import SwiftUI
import SwiftData

struct AddExpenseModalView: View {
    enum AddMode: String, CaseIterable, Identifiable {
        case daily
        case monthly
        case yearly

        var id: Self { self }
    }

    @Environment(\.modelContext) private var context

    let defaultTab: AddMode
    let onClose: () -> Void

    @State private var mode: AddMode
    @State private var amount: String = ""
    @State private var name: String = ""
    @State private var selectedCategory: ExpenseCategory = .groceries
    @State private var expenseType: ExpenseType = .fixed
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    init(defaultTab: AddMode, onClose: @escaping () -> Void) {
        self.defaultTab = defaultTab
        self.onClose = onClose
        _mode = State(initialValue: defaultTab)
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(JColor.border)
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            VStack(spacing: 16) {
                header
                modeTabs
                amountCard
                descriptionCard
                if mode == .daily {
                    categoryCard
                    dayCard
                } else {
                    typeCard
                    scheduleCard
                }
                addButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("New Expense")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)
                Text("Create and track")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(JColor.sub)
            }
            Spacer()
            Button(action: onClose) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(JColor.border, lineWidth: 1.5))
                    .overlay(Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundColor(JColor.sub))
            }
            .buttonStyle(.plain)
        }
    }

    private var modeTabs: some View {
        HStack(spacing: 0) {
            ForEach(AddMode.allCases) { tab in
                Button {
                    mode = tab
                } label: {
                    Text(tab.rawValue.capitalized)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(mode == tab ? .white : JColor.sub)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(mode == tab ? JColor.primary : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AMOUNT")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)

            HStack(spacing: 8) {
                Text("₹")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(JColor.sub)
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(JColor.text)
            }
        }
        .padding(16)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)
            TextField("Expense name", text: $name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(JColor.text)
        }
        .padding(16)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORY")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 105), spacing: 8)], spacing: 8) {
                ForEach(ExpenseCategory.allCases) { cat in
                    let selected = selectedCategory == cat
                    Button {
                        selectedCategory = cat
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.systemImage)
                                .font(.system(size: 12, weight: .bold))
                            Text(cat.displayTitle)
                                .lineLimit(1)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(selected ? .white : JColor.sub)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selected ? JColor.primary : .white)
                        .overlay(
                            Capsule().stroke(selected ? JColor.primary : JColor.border, lineWidth: 1.4)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var dayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DATE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)

            Menu {
                ForEach(1...31, id: \.self) { day in
                    Button("Day \(day)") { selectedDay = day }
                }
            } label: {
                fieldLabel("Day \(selectedDay)")
            }
        }
        .padding(16)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var typeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TYPE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)

            HStack(spacing: 10) {
                typeButton(.fixed)
                typeButton(.variable)
            }
        }
        .padding(16)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func typeButton(_ t: ExpenseType) -> some View {
        Button {
            expenseType = t
        } label: {
            Text(t.displayTitle)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(expenseType == t ? .white : JColor.sub)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(expenseType == t ? JColor.primary : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: expenseType == t ? JColor.primary.opacity(0.28) : Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SCHEDULE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(JColor.sub)

            HStack(spacing: 10) {
                Menu {
                    ForEach(1...12, id: \.self) { month in
                        Button(shortMonth(month)) { selectedMonth = month }
                    }
                } label: {
                    fieldLabel(shortMonth(selectedMonth))
                }

                Menu {
                    ForEach(yearRange, id: \.self) { year in
                        Button(String(year)) { selectedYear = year }
                    }
                } label: {
                    fieldLabel(String(selectedYear))
                }

                if mode == .monthly {
                    Menu {
                        ForEach(1...31, id: \.self) { day in
                            Button("Day \(day)") { selectedDay = day }
                        }
                    } label: {
                        fieldLabel("Day \(selectedDay)")
                    }
                }
            }
        }
        .padding(16)
        .background(JColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var addButton: some View {
        Button {
            saveExpense()
        } label: {
            Text("✓ Add Expense")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(LinearGradient(colors: [JColor.primary, Color(hex: "#9B59B6")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: JColor.primary.opacity(0.4), radius: 12, x: 0, y: 8)
        }
        .disabled(!canSave)
        .opacity(canSave ? 1 : 0.5)
        .buttonStyle(.plain)
    }

    private func fieldLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(JColor.text)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(JColor.sub)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (Double(amount) ?? 0) > 0
    }

    private var yearRange: [Int] {
        let y = Calendar.current.component(.year, from: Date())
        return Array((y - 1)...(y + 5))
    }

    private func shortMonth(_ month: Int) -> String {
        DateFormatter().shortMonthSymbols[month - 1]
    }

    private func saveExpense() {
        let value = Double(amount) ?? 0
        let service = FinanceDataService(context: context)

        let frequency: ExpenseFrequency
        switch mode {
        case .daily: frequency = .daily
        case .monthly: frequency = .monthly
        case .yearly: frequency = .yearly
        }

        let expense = ExpenseModel(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: value,
            type: expenseType,
            category: selectedCategory,
            frequency: frequency,
            day: mode == .daily ? selectedDay : nil,
            month: selectedMonth,
            year: selectedYear,
            startMonth: mode == .monthly ? selectedMonth : nil,
            startYear: mode == .monthly || mode == .yearly ? selectedYear : nil,
            endMonth: mode == .monthly ? selectedMonth : nil,
            endYear: mode == .monthly || mode == .yearly ? selectedYear : nil,
            dueDay: mode == .monthly ? selectedDay : nil
        )

        service.expenseUnified(expense: expense, actionType: .add)
        onClose()
    }
}
