import SwiftUI
import SwiftData
import Foundation

struct AddEditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let expense: ExpenseModel
    private let dataService: FinanceDataService

    @State private var name: String
    @State private var amount: String
    @State private var type: ExpenseType
    @State private var category: ExpenseCategory
    @State private var frequency: ExpenseFrequency
    @State private var actionType: ExpenseActionType

    @State private var month: Int
    @State private var year: Int
    @State private var startMonth: Int
    @State private var startYear: Int
    @State private var endMonth: Int
    @State private var endYear: Int
    @State private var dailyDate: Date

    @State private var dueDay: Int?
    @State private var note: String

    @State private var showPaymentDetailsSheet = false
    @FocusState private var isAmountFocused: Bool
    @State private var impact = UIImpactFeedbackGenerator(style: .medium)

    @State private var showApplyScopeDialog = false
    @State private var validationMessage: String?

    init(expense: ExpenseModel, actionType: ExpenseActionType, context: ModelContext) {
        self.expense = expense
        self.actionType = actionType
        self.dataService = FinanceDataService(context: context)

        _name = State(initialValue: expense.name)
        _amount = State(initialValue: expense.amount == 0 ? "" : String(Int(expense.amount)))
        _type = State(initialValue: expense.type)
        _category = State(initialValue: expense.category ?? .other)
        _frequency = State(initialValue: expense.frequency)

        _month = State(initialValue: expense.month)
        _year = State(initialValue: expense.year)
        _startMonth = State(initialValue: expense.startMonth ?? expense.month)
        _startYear = State(initialValue: expense.startYear ?? expense.year)
        _endMonth = State(initialValue: expense.endMonth ?? expense.month)
        _endYear = State(initialValue: expense.endYear ?? expense.year)

        let fallbackDate = Calendar.current.date(from: DateComponents(year: expense.year, month: expense.month, day: expense.day ?? 1)) ?? Date()
        _dailyDate = State(initialValue: fallbackDate)

        _dueDay = State(initialValue: expense.dueDay)
        _note = State(initialValue: expense.note ?? "")
    }

    var body: some View {
        ZStack {
            ThemeColors.backgroundTop
                .ignoresSafeArea()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {
                        title

                        if let message = validationMessage {
                            Text(message)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(ThemeColors.negative)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(ThemeColors.negative.opacity(0.09))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        amountCard
                        detailsCard
                        scheduleCard
                        noteCard

                        if actionType == .update, expense.isPaid {
                            paidCard
                        }

                        if actionType == .update {
                            deleteButton
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .navigationBarHidden(true)
                .safeAreaInset(edge: .bottom) { actionBar }
                .onAppear {
                    impact.prepare()
                    if actionType == .add {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isAmountFocused = true }
                    }
                }
                .sheet(isPresented: $showPaymentDetailsSheet) {
                    PaymentDetailsSheet(expense: expense, context: context)
                }
                .confirmationDialog("Apply changes to", isPresented: $showApplyScopeDialog, titleVisibility: .visible) {
                    Button("This expense only") {
                        expense.frequency = .oneTime
                        expense.month = month
                        expense.year = year
                        expense.day = nil
                        expense.startMonth = nil
                        expense.startYear = nil
                        expense.endMonth = nil
                        expense.endYear = nil
                        dataService.expenseUnified(expense: expense, actionType: actionType)
                        dismiss()
                    }

                    Button("All recurring expenses") {
                        dataService.expenseUnified(expense: expense, actionType: actionType)
                        dismiss()
                    }

                    Button("Cancel", role: .cancel) { actionType = .update }
                } message: {
                    Text("This expense is recurring.")
                }
            }
        }
    }

    private var title: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(actionType == .add ? "New Expense" : "Edit Expense")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimary)
                Text("Amount, details and schedule")
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(ThemeColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(ThemeColors.cardElevated)
                    .clipShape(Circle())
            }
        }
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Amount")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)

            HStack(spacing: 6) {
                Text("₹")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.textSecondary)
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimary)
                    .focused($isAmountFocused)
                    .onChange(of: amount) { _, _ in
                        validationMessage = nil
                        let filtered = amount.filter { $0.isNumber || $0 == "." }
                        let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
                        amount = parts.count > 2 ? String(parts[0]) + "." + String(parts[1]) : filtered
                    }
            }

            Text("Enter exact amount")
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondary)
        }
        .padding(16)
        .modernCard()
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Details")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Expense Name")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(ThemeColors.textSecondary)
                TextField("Rent, Electricity, Internet...", text: $name)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .background(ThemeColors.cardElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .onChange(of: name) { _, _ in validationMessage = nil }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Category Type")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(ThemeColors.textSecondary)
                Picker("Type", selection: $type) {
                    ForEach(ExpenseType.allCases) { t in
                        Text(t.displayTitle).tag(t)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Frequency")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(ThemeColors.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ExpenseFrequency.allCases) { item in
                            Button {
                                frequency = item
                            } label: {
                                Text(item.displayTitle)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(frequency == item ? .white : ThemeColors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        frequency == item
                                        ? AnyShapeStyle(ThemeGradients.accentGradient)
                                        : AnyShapeStyle(ThemeColors.cardElevated)
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(ThemeColors.textSecondary)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 14, alignment: .leading),
                        GridItem(.flexible(), spacing: 14, alignment: .leading)
                    ],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(ExpenseCategory.allCases) { item in
                        Button { category = item } label: {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: item.systemImage)
                                        .font(.system(size: 13, weight: .bold))
                                    Text(item.displayTitle)
                                        .font(.caption.weight(.semibold))
                                        .lineLimit(1)
                                }
                                Spacer(minLength: 0)
                            }
                            .foregroundColor(category == item ? .white : ThemeColors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                category == item
                                ? AnyShapeStyle(LinearGradient(colors: [ThemeColors.accent, ThemeColors.accent.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                : AnyShapeStyle(ThemeStore.shared.isDarkMode ? Color.white.opacity(0.08) : Color(red: 0.95, green: 0.96, blue: 0.98))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(category == item ? Color.clear : ThemeColors.cardBorder.opacity(0.45), lineWidth: 0.9)
                            )
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if frequency != .daily {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Due Day")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(ThemeColors.textSecondary)
                    Menu {
                        Button("None") { dueDay = nil }
                        ForEach(1...31, id: \.self) { day in
                            Button("Day \(day)") { dueDay = day }
                        }
                    } label: {
                        compactMenuFieldLabel(value: dueDay == nil ? "None" : "Day \(dueDay!)")
                    }
                }
            }
        }
        .padding(16)
        .modernCard()
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Schedule")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)

            switch frequency {
            case .daily:
                DatePicker("Date", selection: $dailyDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)

            case .oneTime:
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Month")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ThemeColors.textSecondary)
                        monthMenu(selected: $month)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Year")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ThemeColors.textSecondary)
                        yearMenu(selected: $year)
                    }
                }

            case .monthly:
                VStack(alignment: .leading, spacing: 10) {
                    Text("Start")
                        .font(.caption.weight(.bold))
                        .foregroundColor(ThemeColors.textSecondary)
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Month")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(ThemeColors.textSecondary)
                            monthMenu(selected: $startMonth)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(ThemeColors.textSecondary)
                            yearMenu(selected: $startYear)
                        }
                    }

                    Text("End")
                        .font(.caption.weight(.bold))
                        .foregroundColor(ThemeColors.textSecondary)
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Month")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(ThemeColors.textSecondary)
                            monthMenu(selected: $endMonth)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(ThemeColors.textSecondary)
                            yearMenu(selected: $endYear)
                        }
                    }
                }

            case .yearly:
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Month")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(ThemeColors.textSecondary)
                            monthMenu(selected: $month)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("From")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(ThemeColors.textSecondary)
                            yearMenu(selected: $startYear)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("To")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ThemeColors.textSecondary)
                        yearMenu(selected: $endYear)
                    }
                }
            }
        }
        .padding(16)
        .modernCard()
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)
            TextEditor(text: $note)
                .frame(minHeight: 80)
                .padding(8)
                .background(ThemeColors.cardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .modernCard()
    }

    private var paidCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)
            Button { showPaymentDetailsSheet = true } label: {
                HStack {
                    Label("View or edit payment details", systemImage: "creditcard")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ThemeColors.accent)
                .padding(12)
                .background(ThemeColors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .modernCard()
    }

    private var deleteButton: some View {
        Button(role: .destructive, action: deleteExpense) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Expense")
            }
            .font(.subheadline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .background(ThemeColors.negative.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("Cancel") { dismiss() }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ThemeColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(ThemeColors.cardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                if validate() {
                    impact.impactOccurred()
                    saveUpdateExpense()
                }
            } label: {
                Text(actionType == .add ? "Add Expense" : "Save Changes")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(ThemeGradients.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.55)
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }

    private func monthMenu(selected: Binding<Int>) -> some View {
        Menu {
            ForEach(1...12, id: \.self) { value in
                Button(monthName(value)) { selected.wrappedValue = value }
            }
        } label: {
            compactMenuFieldLabel(value: monthName(selected.wrappedValue))
        }
    }

    private func yearMenu(selected: Binding<Int>) -> some View {
        Menu {
            ForEach(yearRange, id: \.self) { value in
                Button(String(value)) { selected.wrappedValue = value }
            }
        } label: {
            compactMenuFieldLabel(value: String(selected.wrappedValue))
        }
    }

    private func compactMenuFieldLabel(value: String) -> some View {
        HStack(spacing: 8) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ThemeColors.textPrimary)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundColor(ThemeColors.textSecondary)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(ThemeColors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private extension AddEditExpenseView {
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil
    }

    private func validate() -> Bool {
        validationMessage = nil

        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Expense name is required."
            return false
        }

        guard let value = Double(amount), value > 0 else {
            validationMessage = "Enter a valid amount greater than 0."
            return false
        }

        switch frequency {
        case .daily:
            break
        case .oneTime:
            if month < 1 || month > 12 {
                validationMessage = "Select a valid month."
                return false
            }
        case .monthly:
            if (startYear > endYear) || (startYear == endYear && startMonth > endMonth) {
                validationMessage = "Start date must be before end date."
                return false
            }
        case .yearly:
            if startYear > endYear {
                validationMessage = "Start year must be before end year."
                return false
            }
        }

        if frequency != .daily, let day = dueDay, day < 1 || day > 31 {
            validationMessage = "Enter a valid due day."
            return false
        }

        return true
    }

    func saveUpdateExpense() {
        let finalAmount = Double(amount) ?? 0

        expense.name = name
        expense.amount = finalAmount
        expense.type = type
        expense.category = category
        expense.frequency = frequency
        expense.month = month
        expense.year = year

        switch frequency {
        case .daily:
            let comps = Calendar.current.dateComponents([.day, .month, .year], from: dailyDate)
            expense.day = comps.day
            expense.month = comps.month ?? month
            expense.year = comps.year ?? year
            expense.startMonth = nil
            expense.startYear = nil
            expense.endMonth = nil
            expense.endYear = nil

        case .oneTime:
            expense.day = nil
            expense.month = month
            expense.year = year
            expense.startMonth = nil
            expense.startYear = nil
            expense.endMonth = nil
            expense.endYear = nil

        case .monthly:
            expense.day = nil
            expense.startMonth = startMonth
            expense.startYear = startYear
            expense.endMonth = endMonth
            expense.endYear = endYear
            expense.month = startMonth
            expense.year = startYear

        case .yearly:
            expense.day = nil
            expense.startMonth = nil
            expense.startYear = startYear
            expense.endMonth = nil
            expense.endYear = endYear
            expense.month = month
            expense.year = startYear
        }

        expense.dueDay = frequency == .daily ? nil : dueDay
        expense.note = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if actionType == .update && (expense.frequency == .monthly || expense.frequency == .yearly) {
            showApplyScopeDialog = true
        } else {
            dataService.expenseUnified(expense: expense, actionType: actionType)
            dismiss()
        }
    }

    func deleteExpense() {
        impact.impactOccurred()
        actionType = .delete

        if expense.frequency == .monthly || expense.frequency == .yearly {
            showApplyScopeDialog = true
        } else {
            dataService.expenseUnified(expense: expense, actionType: .delete)
            dismiss()
        }
    }

    var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 5)...(currentYear + 10))
    }

    func monthName(_ month: Int) -> String {
        DateFormatter().shortMonthSymbols[month - 1]
    }
}
