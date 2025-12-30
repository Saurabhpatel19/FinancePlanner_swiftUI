//
//  AddEditExpenseView.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import SwiftUI
import SwiftData

enum expenseActionType {
    case add
    case update
    case delete
}
struct AddEditExpenseView: View {

    @Environment(\.dismiss) private var dismiss
    // SwiftData
    @Environment(\.modelContext) private var context
    @Query(sort: \MonthModel.title) private var storedMonths: [MonthModel]
    
    var dataService: FinanceDataService {
        FinanceDataService(context: context,
                           monthsUI: monthsUI,
                           storedMonths: storedMonths)
    }
    
    let expense: ExpenseModel
    let monthsUI: [MonthUI]
    let selectedMonthIndex: Int
    
    // MARK: - Local State
    @State private var name: String
    @State private var amount: String
    @State private var type: ExpenseType
    @State private var frequency: ExpenseFrequency
    @State private var currentActionType: expenseActionType

    @State private var showApplyConfirmDialog = false

    @State private var selectedStartMonthIndex: Int

    init(
        expense: ExpenseModel,
        monthsUI: [MonthUI],
        selectedMonthIndex: Int,
        actionType: expenseActionType
    ) {
        self.expense = expense
        self.monthsUI = monthsUI
        self.selectedMonthIndex = selectedMonthIndex
        self.currentActionType = actionType

        _name = State(initialValue: expense.name)
        _amount = State(initialValue: expense.amount == 0 ? "" : String(Int(expense.amount)))
        _type = State(initialValue: expense.type)
        _frequency = State(initialValue: expense.frequency)
        _currentActionType = State(initialValue: actionType)

        _selectedStartMonthIndex = State(initialValue: selectedMonthIndex)
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Expense
                Section("Expense") {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.numberPad)
                }

                // MARK: - Type
                Section("Type") {
                    Picker("Type", selection: $type) {
                        Text("Fixed").tag(ExpenseType.fixed)
                        Text("Variable").tag(ExpenseType.variable)
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Frequency
                Section("Frequency") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ExpenseFrequency.allCases) { freq in
                            Text(freq.displayTitle)
                                .tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    let title = frequency.affectsFutureMonths ? "Start Month" : "Month"
                    Picker(title, selection: $selectedStartMonthIndex) {
                        ForEach(selectedMonthIndex..<monthsUI.count, id: \.self) { index in
                            Text(monthsUI[index].title)
                                .tag(index)
                        }
                    }
                }

                // MARK: - Delete Expense
                if currentActionType == .update {
                    Button("Delete") {
                        // 🔥 EDIT CASE: ask confirmation if future months are involved
                        currentActionType = .delete
                        if frequency.affectsFutureMonths {
                            showApplyConfirmDialog = true
                        } else {
                            dataService.expenseUnified(expense: expense, startMonthIndex: selectedStartMonthIndex, actionType: currentActionType)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {

                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // Save
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {

                        expense.name = name
                        expense.amount = Double(amount) ?? 0
                        expense.type = type
                        expense.frequency = frequency

                        
                        let applyToFuture = frequency.affectsFutureMonths
                        
                        // 🔥 EDIT CASE: ask confirmation if future months are involved
                        if currentActionType == .update ,applyToFuture {
                            showApplyConfirmDialog = true
                        } else {
                            dataService.expenseUnified(expense: expense, startMonthIndex: selectedStartMonthIndex, actionType: currentActionType)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
            
            .confirmationDialog(
                "Apply changes to",
                isPresented: $showApplyConfirmDialog,
                titleVisibility: .visible
            ) {

                Button("This month only") {
                    // NOTE:
                    // Frequency is temporarily mutated to oneTime
                    // to scope edit to current month only.
                    // Future refactor may replace this with explicit scope handling.
                    if expense.frequency != .oneTime {
                        expense.frequency = .oneTime
                    }
                    dataService.expenseUnified(expense: expense, startMonthIndex: selectedStartMonthIndex, actionType: currentActionType)
                    dismiss()
                }

                Button("This & future months") {
                    // When applying to future, respect the selected start month if the user chose it; otherwise use current month
                    dataService.expenseUnified(expense: expense, startMonthIndex: selectedStartMonthIndex, actionType: currentActionType)
                    dismiss()
                }

                Button("Cancel", role: .cancel) {
                    currentActionType = .update
                }
            }

        }
    }
}

