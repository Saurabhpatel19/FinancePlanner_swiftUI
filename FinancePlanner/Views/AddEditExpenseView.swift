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

    // MARK: - Inputs
    let expense: ExpenseModel
//    var actionType: ExpenseActionType
    private let dataService: FinanceDataService

    // MARK: - Editable State
    @State private var name: String
    @State private var amount: String
    @State private var type: ExpenseType
    @State private var frequency: ExpenseFrequency
    @State private var month: Int
    @State private var year: Int
    @State private var actionType: ExpenseActionType

    // MARK: - UI State
    @State private var showApplyScopeDialog = false

    // MARK: - Init
    init(
        expense: ExpenseModel,
        actionType: ExpenseActionType,
        context: ModelContext
    ) {
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
        _year = State(initialValue: expense.year)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Expense Details
                Section("Expense Details") {
                    TextField("Name", text: $name)

                    TextField("Amount", text: $amount)
                        .keyboardType(.numberPad)
                }

                // MARK: - Schedule
                Section("Schedule") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ExpenseFrequency.allCases) { freq in
                            Text(freq.displayTitle)
                                .tag(freq)
                        }
                    }

                    Picker("Month", selection: $month) {
                        ForEach(1...12, id: \.self) { m in
                            Text(monthName(m)).tag(m)
                        }
                    }

                    Picker("Year", selection: $year) {
                        ForEach(yearRange, id: \.self) { y in
                            Text(String(y)).tag(y)
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
                        saveUpdateExpense()
                    }
                    .disabled(!isValid)
                }
            }
        }
        // MARK: - Apply Scope Dialog
        .confirmationDialog(
            "Apply changes to",
            isPresented: $showApplyScopeDialog,
            titleVisibility: .visible
        ) {

            Button("This expense only") {
                expense.frequency = .oneTime
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
    }
}

private extension AddEditExpenseView {

    // MARK: - Validation
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil
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



