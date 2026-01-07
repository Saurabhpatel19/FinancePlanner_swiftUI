//
//  AddEditExpenseView.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import SwiftUI
import SwiftData
import Foundation

struct AddEditExpenseView: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // MARK: - Inputs
    let expense: ExpenseModel
    private let dataService: FinanceDataService

    // MARK: - Editable State
    @State private var name: String
    @State private var amount: String
    @State private var type: ExpenseType
    @State private var frequency: ExpenseFrequency
    @State private var actionType: ExpenseActionType

    @State private var month: Int          // oneTime only
    @State private var year: Int

    @State private var startMonth: Int
    @State private var startYear: Int
    
    @State private var endMonth: Int
    @State private var endYear: Int
    
    @State private var dueDay: Int?
    @State private var note: String
    
    @State private var showPaymentDetailsSheet = false

    // MARK: - UI State
    @State private var showApplyScopeDialog = false
    
    //MARK: -Validation
    @State private var validationMessage: String? = nil

    // MARK: - Init
    init(
        expense: ExpenseModel,
        actionType: ExpenseActionType,
        context: ModelContext
    )
    {
        self.expense = expense
        self.actionType = actionType
        self.dataService = FinanceDataService(context: context)

        _name = State(initialValue: expense.name)
        _amount = State(
            initialValue: expense.amount == 0 ? "" : String(Int(expense.amount))
        )
        _type = State(initialValue: expense.type)
        _frequency = State(initialValue: expense.frequency)
                
        _month = State(initialValue: expense.month)
        _year  = State(initialValue: expense.year)

        _startMonth = State(initialValue: expense.startMonth ?? expense.month)
        _startYear  = State(initialValue: expense.startYear  ?? expense.year)

        _endMonth = State(initialValue: expense.endMonth ?? expense.month)
        _endYear  = State(initialValue: expense.endYear  ?? expense.year)

        _dueDay = State(initialValue: expense.dueDay)
        _note   = State(initialValue: expense.note ?? "")

    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // White background with trading UI theme
            ThemeColors.background
                .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 16) {
                    
                    // Header with title and gradient accent
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(actionType == .add ? "New Expense" : "Edit Expense")
                                    .font(.system(size: 28, weight: .bold, design: .default))
                                    .foregroundColor(ThemeColors.textPrimary)
                                
                                Text(actionType == .add ? "Create and track" : "Update your expense")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    // Validation Alert
                    if let message = validationMessage {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Content scroll view
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            // MARK: - Amount Card (Trading-style)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Amount")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                HStack(spacing: 4) {
                                    Text("₹")
                                        .font(.system(size: 32, weight: .semibold, design: .default))
                                        .foregroundColor(ThemeColors.textSecondary)
                                    
                                    TextField("0", text: $amount)
                                        .font(.system(size: 32, weight: .semibold, design: .default))
                                        .foregroundColor(Double(amount) ?? 0 > 0 ? ThemeColors.positive : ThemeColors.textSecondary)
                                        .keyboardType(.decimalPad)
                                        .onChange(of: amount) { _, _ in validationMessage = nil }
                                    
                                    Spacer()
                                }
                                
                                // Amount indicator bar
                                if let value = Double(amount), value > 0 {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(ThemeColors.textTertiary.opacity(0.15))
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(ThemeGradients.positiveGradient)
                                                .frame(width: min(geo.size.width * CGFloat(min(value / 100000, 1)), geo.size.width))
                                        }
                                    }
                                    .frame(height: 6)
                                }
                            }
                            .padding(16)
                            .background(ThemeColors.cardBackground)
                            .border(ThemeColors.cardBorder, width: 1)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // MARK: - Name Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Description")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                TextField("Expense name", text: $name)
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(ThemeColors.textPrimary)
                                    .onChange(of: name) { _, _ in validationMessage = nil }
                                    .tint(ThemeColors.accent)
                            }
                            .padding(16)
                            .background(ThemeColors.cardBackground)
                            .border(ThemeColors.cardBorder, width: 1)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // MARK: - Type & Frequency Grid
                            VStack(spacing: 12) {
                                // Type Card
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Category Type")
                                        .font(.system(size: 13, weight: .semibold, design: .default))
                                        .foregroundColor(ThemeColors.textSecondary)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                    
                                    HStack(spacing: 8) {
                                        ForEach(ExpenseType.allCases) { t in
                                            Button(action: { type = t }) {
                                                Text(t.displayTitle)
                                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(10)
                                                    .background(
                                                        type == t ?
                                                        ThemeGradients.accentGradient :
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                ThemeColors.buttonBackground,
                                                                ThemeColors.buttonBackground.opacity(0.7)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .foregroundColor(type == t ? .white : ThemeColors.textPrimary)
                                                    .cornerRadius(8)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(
                                                                type == t ?
                                                                ThemeColors.accentPurple :
                                                                ThemeColors.cardBorder,
                                                                lineWidth: 1
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                }
                                .padding(16)
                                .background(ThemeColors.cardBackground)
                                .border(ThemeColors.cardBorder, width: 1)
                                .cornerRadius(12)
                                
                                // Frequency Card
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Frequency")
                                        .font(.system(size: 13, weight: .semibold, design: .default))
                                        .foregroundColor(ThemeColors.textSecondary)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                    
                                    if actionType == .add {
                                        Picker("Frequency", selection: $frequency) {
                                            ForEach(ExpenseFrequency.allCases) { freq in
                                                Text(freq.displayTitle).tag(freq)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                        .tint(ThemeColors.accent)
                                    } else {
                                        HStack {
                                            Text(frequency.displayTitle)
                                                .font(.system(size: 16, weight: .medium, design: .default))
                                                .foregroundColor(ThemeColors.textPrimary)
                                            Spacer()
                                            Text("(Fixed)")
                                                .font(.caption)
                                                .foregroundColor(ThemeColors.textSecondary)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(ThemeColors.cardBackground)
                                .border(ThemeColors.cardBorder, width: 1)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            
                            // MARK: - Schedule Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Schedule")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                VStack(spacing: 12) {
                                    switch frequency {
                                    case .oneTime:
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Month")
                                                    .font(.caption)
                                                    .foregroundColor(ThemeColors.textSecondary)
                                                Picker("Month", selection: $month) {
                                                    ForEach(1...12, id: \.self) {
                                                        Text(monthName($0)).tag($0)
                                                    }
                                                }
                                                .tint(ThemeColors.accent)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Year")
                                                    .font(.caption)
                                                    .foregroundColor(ThemeColors.textSecondary)
                                                Picker("Year", selection: $year) {
                                                    ForEach(yearRange, id: \.self) {
                                                        Text(String($0)).tag($0)
                                                    }
                                                }
                                                .tint(ThemeColors.accent)
                                            }
                                        }
                                        
                                    case .monthly:
                                        VStack(spacing: 12) {
                                            Text("Start Date")
                                                .font(.caption2)
                                                .foregroundColor(ThemeColors.textSecondary)
                                            
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Month")
                                                        .font(.caption)
                                                        .foregroundColor(ThemeColors.textSecondary)
                                                    Picker("Start Month", selection: $startMonth) {
                                                        ForEach(1...12, id: \.self) {
                                                            Text(monthName($0)).tag($0)
                                                        }
                                                    }
                                                    .tint(ThemeColors.accent)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Year")
                                                        .font(.caption)
                                                        .foregroundColor(ThemeColors.textSecondary)
                                                    Picker("Start Year", selection: $startYear) {
                                                        ForEach(yearRange, id: \.self) {
                                                            Text(String($0)).tag($0)
                                                        }
                                                    }
                                                    .tint(ThemeColors.accent)
                                                }
                                            }
                                            
                                            Divider()
                                                .background(ThemeColors.cardBackground)
                                            
                                            Text("End Date")
                                                .font(.caption2)
                                                .foregroundColor(ThemeColors.textSecondary)
                                            
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Month")
                                                        .font(.caption)
                                                        .foregroundColor(ThemeColors.textSecondary)
                                                    Picker("End Month", selection: $endMonth) {
                                                        ForEach(1...12, id: \.self) {
                                                            Text(monthName($0)).tag($0)
                                                        }
                                                    }
                                                    .tint(ThemeColors.accent)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Year")
                                                        .font(.caption)
                                                        .foregroundColor(ThemeColors.textSecondary)
                                                    Picker("End Year", selection: $endYear) {
                                                        ForEach(yearRange, id: \.self) {
                                                            Text(String($0)).tag($0)
                                                        }
                                                    }
                                                    .tint(ThemeColors.accent)
                                                }
                                            }
                                        }
                                        
                                    case .yearly:
                                        VStack(spacing: 12) {
                                            Text("Month of Occurrence")
                                                .font(.caption2)
                                                .foregroundColor(ThemeColors.textSecondary)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Month")
                                                    .font(.caption)
                                                    .foregroundColor(ThemeColors.textSecondary)
                                                Picker("Month", selection: $month) {
                                                    ForEach(1...12, id: \.self) {
                                                        Text(monthName($0)).tag($0)
                                                    }
                                                }
                                                .tint(ThemeColors.accent)
                                            }
                                            
                                            Divider()
                                                .background(ThemeColors.cardBackground)
                                            
                                            Text("Duration")
                                                .font(.caption2)
                                                .foregroundColor(ThemeColors.textSecondary)
                                            
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("From Year")
                                                        .font(.caption)
                                                        .foregroundColor(ThemeColors.textSecondary)
                                                    Picker("Start Year", selection: $startYear) {
                                                        ForEach(yearRange, id: \.self) {
                                                            Text(String($0)).tag($0)
                                                        }
                                                    }
                                                    .tint(ThemeColors.accent)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("To Year")
                                                        .font(.caption)
                                                        .foregroundColor(ThemeColors.textSecondary)
                                                    Picker("End Year", selection: $endYear) {
                                                        ForEach(yearRange, id: \.self) {
                                                            Text(String($0)).tag($0)
                                                        }
                                                    }
                                                    .tint(ThemeColors.accent)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(16)
                                .background(ThemeColors.cardBackground)
                                .border(ThemeColors.cardBorder, width: 1)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            
                            // MARK: - Due Day Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Due / ECS Day")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                Picker("Day", selection: $dueDay) {
                                    Text("None").tag(Int?.none)
                                    ForEach(1...31, id: \.self) {
                                        Text("\($0)").tag(Optional($0))
                                    }
                                }
                                .tint(ThemeColors.accent)
                            }
                            .padding(16)
                            .background(ThemeColors.cardBackground)
                            .border(ThemeColors.cardBorder, width: 1)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // MARK: - Notes Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Notes")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                TextEditor(text: $note)
                                    .font(.system(size: 14, design: .default))
                                    .foregroundColor(ThemeColors.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .background(ThemeColors.background)
                                    .frame(minHeight: 80)
                                    .cornerRadius(8)
                                    .border(ThemeColors.cardBorder, width: 1)
                            }
                            .padding(16)
                            .background(ThemeColors.cardBackground)
                            .border(ThemeColors.cardBorder, width: 1)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            // MARK: - Payment Status Card (Edit only)
                            if actionType == .update, expense.isPaid {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Payment Status")
                                                .font(.system(size: 13, weight: .semibold, design: .default))
                                                .foregroundColor(ThemeColors.textSecondary)
                                                .textCase(.uppercase)
                                                .tracking(0.5)
                                            
                                            HStack(spacing: 8) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                                                Text("Paid")
                                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                                    .foregroundColor(ThemeColors.textPrimary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    
                                    Button(action: { showPaymentDetailsSheet = true }) {
                                        HStack {
                                            Text("View / Edit Payment Details")
                                                .font(.system(size: 14, weight: .medium, design: .default))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .foregroundColor(ThemeColors.accent)
                                        .padding(12)
                                        .background(ThemeColors.accent.opacity(0.08))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(16)
                                .background(ThemeColors.cardBackground)
                                .border(ThemeColors.cardBorder, width: 1)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                            
                            // MARK: - Delete Button (Edit only)
                            if actionType == .update {
                                Button(role: .destructive, action: deleteExpense) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Delete Expense")
                                    }
                                    .font(.system(size: 15, weight: .semibold, design: .default))
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(ThemeColors.negative.opacity(0.08))
                                    .foregroundColor(ThemeColors.negative)
                                    .cornerRadius(8)
                                    .border(ThemeColors.negative.opacity(0.2), width: 1)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }
                            
                            // Bottom spacing
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                    
                    // MARK: - Action Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                dismiss()
                            }
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(ThemeColors.buttonBackground)
                            .foregroundColor(ThemeColors.textSecondary)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(ThemeColors.buttonBorder, lineWidth: 1)
                            )
                            
                            Button(action: {
                                if validate() {
                                    saveUpdateExpense()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark")
                                    Text("Save")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(
                                    isValid ?
                                    ThemeGradients.positiveGradient :
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ThemeColors.textTertiary.opacity(0.3),
                                            ThemeColors.textTertiary.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(!isValid)
                        }
                    }
                    .padding(20)
                    .background(ThemeColors.cardBackground)
                    .border(ThemeColors.cardBorder, width: 1)
                }
                .sheet(isPresented: $showPaymentDetailsSheet) {
                    PaymentDetailsSheet(
                        expense: expense,
                        context: context
                    )
                }
                .confirmationDialog(
                    "Apply changes to",
                    isPresented: $showApplyScopeDialog,
                    titleVisibility: .visible
                )
                {
                    Button("This expense only") {
                        expense.frequency = .oneTime
                        
                        expense.month = month
                        expense.year = year
                        
                        expense.startMonth = nil
                        expense.startYear = nil
                        
                        expense.endMonth = nil
                        expense.endYear = nil
                        
                        dataService.expenseUnified(
                            expense: expense,
                            actionType: actionType
                        )
                        dismiss()
                    }

                    Button("All recurring expenses") {
                        dataService.expenseUnified(
                            expense: expense,
                            actionType: actionType
                        )
                        dismiss()
                    }

                    Button("Cancel", role: .cancel) {
                        actionType = .update
                    }
                } message: {
                    Text("This expense is recurring.")
                }
                
                .animation(.easeInOut, value: validationMessage)
            }
        }
    }
}

private extension AddEditExpenseView {

    // MARK: - Validation
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil
    }

    private func validate() -> Bool {
        validationMessage = nil

        // Common
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Expense name is required."
            return false
        }

        guard let value = Double(amount), value > 0 else {
            validationMessage = "Enter a valid amount greater than 0."
            return false
        }

        // Frequency-specific
        switch frequency {

        case .oneTime:
            if month < 1 || month > 12 {
                validationMessage = "Select a valid month."
                return false
            }

        case .monthly:
            if (startYear > endYear) ||
               (startYear == endYear && startMonth > endMonth) {
                validationMessage = "Start date must be before end date."
                return false
            }

        case .yearly:
            if startYear > endYear {
                validationMessage = "Start year must be before end year."
                return false
            }
        }

        if let day = dueDay, day < 1 || day > 31 {
            validationMessage = "Enter a valid due day."
            return false
        }

        
        return true
    }

    
    // MARK: - Save Routing
    func saveUpdateExpense() {
        let finalAmount = Double(amount) ?? 0

        expense.name = name
        expense.amount = finalAmount
        expense.type = type
        expense.frequency = frequency
        expense.month = month
        expense.year = year
        
        switch frequency {
        case .oneTime:
            expense.month = month
            expense.year = year
            
            expense.startMonth = nil
            expense.startYear = nil
            
            expense.endMonth = nil
            expense.endYear = nil
        case .monthly:
            
            expense.startMonth = startMonth
            expense.startYear = startYear
            
            expense.endMonth = endMonth
            expense.endYear = endYear
            
            // 🔒 instance date locked for monthly
            expense.month = startMonth
            expense.year = startYear
            
        case .yearly:
            expense.startMonth = nil
            expense.startYear = startYear
            
            expense.endMonth = nil
            expense.endYear = endYear
            
            // 🔒 instance date locked for monthly
            expense.month = month
            expense.year = startYear
        }
              
        expense.dueDay = dueDay
        expense.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 🔥 EDIT CASE: ask confirmation if future months are involved
        if actionType == .update && expense.frequency != .oneTime {
            showApplyScopeDialog = true
        } else {
            dataService.expenseUnified(
                expense: expense,
                actionType: actionType
            )
            dismiss()
        }
        
    }
    
    // MARK: - Delete
    func deleteExpense() {
        self.actionType = .delete
        // 🔥 EDIT CASE: ask confirmation if future months are involved
        if expense.frequency == .oneTime {
            dataService.expenseUnified(
                expense: expense,
                actionType: .delete
            )
            dismiss()
        } else {
            showApplyScopeDialog = true
        }
    }

    // MARK: - Helpers
    var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 5)...(currentYear + 10))
    }

    func monthName(_ month: Int) -> String {
        DateFormatter().monthSymbols[month - 1]
    }
}



