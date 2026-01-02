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
        NavigationStack {
            VStack(spacing: 0) {

                if let message = validationMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .transition(.move(edge: .top))
                }
                Form {

                    // MARK: - Expense Details
                    Section("Expense Details") {
                        TextField("Name", text: $name)

                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    // MARK: - Schedule
                    Section("Schedule") {
                        
                        if actionType == .add {
                            Picker("Frequency", selection: $frequency) {
                                ForEach(ExpenseFrequency.allCases) { freq in
                                    Text(freq.displayTitle).tag(freq)
                                }
                            }
                        } else {
                            HStack {
                                Text("Frequency")
                                Spacer()
                                Text(frequency.displayTitle)
                                    .foregroundColor(.secondary)
                            }
                        }

                        switch frequency {
                        case .oneTime:
                            Picker("Month", selection: $month) {
                                ForEach(1...12, id: \.self) {
                                    Text(monthName($0)).tag($0)
                                }
                            }

                            Picker("Year", selection: $year) {
                                ForEach(yearRange, id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                        case .monthly:
                            Picker("Start Month", selection: $startMonth) {
                                ForEach(1...12, id: \.self) {
                                    Text(monthName($0)).tag($0)
                                }
                            }

                            Picker("Start Year", selection: $startYear) {
                                ForEach(yearRange, id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                            
                            Picker("End Month", selection: $endMonth) {
                                ForEach(1...12, id: \.self) {
                                    Text(monthName($0)).tag($0)
                                }
                            }

                            Picker("End Year", selection: $endYear) {
                                ForEach(yearRange, id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                        case .yearly:
                            Picker("Month", selection: $month) {
                                ForEach(1...12, id: \.self) {
                                    Text(monthName($0)).tag($0)
                                }
                            }

                            Picker("Start Year", selection: $startYear) {
                                ForEach(yearRange, id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                            
                            Picker("End Year", selection: $endYear) {
                                ForEach(yearRange, id: \.self) {
                                    Text(String($0)).tag($0)
                                }
                            }
                        }
                        
                    }

                    // MARK: - Due / ECS Day
                    Section("Due / ECS Day") {
                        Picker("Day", selection: $dueDay) {
                            Text("None").tag(Int?.none)
                            ForEach(1...31, id: \.self) {
                                Text("\($0)").tag(Optional($0))
                            }
                        }
                    }

                    
                    // MARK: - Type
                    Section("Type") {
                        Picker("Expense Type", selection: $type) {
                            ForEach(ExpenseType.allCases) { t in
                                Text(t.displayTitle)
                                    .tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: - Notes
                    Section("Notes") {
                        TextEditor(text: $note)
                            .frame(minHeight: 80)
                    }

                    // MARK: - Payment (Read-only)
                    if actionType == .update, expense.isPaid {

                        Section("Payment") {

                            HStack {
                                Text("Status")
                                Spacer()
                                Text("Paid")
                                    .foregroundColor(.green)
                            }

                            Button("View / Edit Payment Details") {
                                showPaymentDetailsSheet = true
                            }
                        }
                    }
                    
                    // MARK: - Delete (Edit only)
                    if actionType == .update {
                        Section {
                            Button(role: .destructive) {
                                deleteExpense()
                            } label: {
                                Text("Delete Expense")
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut, value: validationMessage)
            .navigationTitle(actionType == .add ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validate() {
                            saveUpdateExpense()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showPaymentDetailsSheet) {
                PaymentDetailsSheet(
                    expense: expense,
                    context: context
                )
            }
        }
        // MARK: - Apply Scope Dialog
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
        
        .onChange(of: name) { _, _ in validationMessage = nil }
        .onChange(of: amount) { _, _ in validationMessage = nil }
        .onChange(of: frequency) { _, _ in validationMessage = nil }
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



