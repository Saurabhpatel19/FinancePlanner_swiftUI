//
//  FinanceDataService.swift
//  FinancePlanner
//
//  Created by Saurabh on 26/12/25.
//


import SwiftData

final class FinanceDataService {

    private let context: ModelContext
    private let monthsUI: [MonthUI]
    private let storedMonths: [MonthModel]
    
    init(
        context: ModelContext,
        monthsUI: [MonthUI],
        storedMonths: [MonthModel]
    ) {
        self.context = context
        self.monthsUI = monthsUI
        self.storedMonths = storedMonths
    }

    // MARK: - Save (Add / Edit)
    func expenseUnified(
        expense: ExpenseModel,
        startMonthIndex: Int,
        actionType: expenseActionType
    )
    {
        let seriesId = expense.seriesId

        let endIndex: Int
        if expense.frequency == .yearly {
            endIndex = min(startMonthIndex + 12, monthsUI.count - 1)
        } else if expense.frequency.affectsFutureMonths {
            endIndex = monthsUI.count - 1
        } else {
            endIndex = startMonthIndex
        }

        let indices: [Int]
        if expense.frequency == .yearly {
            indices = Array(Set([startMonthIndex, endIndex]))
        } else {
            indices = Array(startMonthIndex...endIndex)
        }

        for index in indices {
            let monthTitle = monthsUI[index].title

            let month = storedMonths.first { $0.title == monthTitle }
            ?? {
                let newMonth = MonthModel(
                    title: monthTitle,
                    status: .draft,
                    fixedExpenses: [],
                    variableExpenses: []
                )
                context.insert(newMonth)
                return newMonth
            }()

            switch actionType {
            case .add:
                let monthUI = monthsUI[index]

                let copy = ExpenseModel(
                    seriesId: seriesId,
                    name: expense.name,
                    amount: expense.amount,
                    type: expense.type,
                    frequency: expense.frequency,
                    month: monthUI.month,
                    year: monthUI.year
                )
                
                if copy.type == .fixed {
                    month.fixedExpenses.append(copy)
                } else {
                    month.variableExpenses.append(copy)
                }

            case .update:
                let all = month.fixedExpenses + month.variableExpenses
                for exp in all where exp.seriesId == seriesId {
                    exp.name = expense.name
                    exp.amount = expense.amount
                    exp.type = expense.type
                    exp.frequency = expense.frequency
                }

            case .delete:
                month.fixedExpenses.removeAll { $0.seriesId == seriesId }
                month.variableExpenses.removeAll { $0.seriesId == seriesId }
            }
        }

        try? context.save()
    }
}
