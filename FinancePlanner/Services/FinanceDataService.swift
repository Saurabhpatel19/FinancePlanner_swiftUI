//
//  FinanceDataService.swift
//  FinancePlanner
//
//  Created by Saurabh on 26/12/25.
//


import SwiftData
import Foundation

enum ExpenseActionType {
    case add
    case update
    case delete
}

final class FinanceDataService {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Unified Add / Update / Delete
    func expenseUnified(
        expense: ExpenseModel,
        actionType: ExpenseActionType
    ) {

        switch actionType {

        // MARK: - ADD
        case .add:
            handleAdd(expense)

        // MARK: - UPDATE
        case .update:
            handleUpdate(expense)

        // MARK: - DELETE
        case .delete:
            handleDelete(expense)
        }

        try? context.save()
    }
}

private extension FinanceDataService {

    // MARK: - Add
    func handleAdd(_ expense: ExpenseModel) {

        let seriesId = expense.seriesId
        let calendar = Calendar.current
        let now = Date()
        
        let currentYear = calendar.component(.year, from: now)
        let endYear = currentYear + 1

        switch expense.frequency {
            
        case .oneTime:
            // Single expense
            let copy = makeCopy(
                from: expense,
                month: expense.month,
                year: expense.year,
                seriesId: seriesId
            )
            context.insert(copy)
            
            // Monthly expense
        case .monthly:
            var month = expense.month
            var year = expense.year
            
            while year < endYear || (year == endYear && month <= 12) {
                
                let copy = makeCopy(
                    from: expense,
                    month: month,
                    year: year,
                    seriesId: seriesId
                )
                context.insert(copy)
                
                // increment month
                month += 1
                if month > 12 {
                    month = 1
                    year += 1
                }
            }
            
        case .yearly:
            // Create for current year and next year
            let current = makeCopy(
                from: expense,
                month: expense.month,
                year: expense.year,
                seriesId: seriesId
            )
            
            let nextYear = makeCopy(
                from: expense,
                month: expense.month,
                year: expense.year + 1,
                seriesId: seriesId
            )
            
            context.insert(current)
            context.insert(nextYear)
        }
    }

    // MARK: - Update
    func handleUpdate(
        _ expense: ExpenseModel
    )
    {
        let descriptor = FetchDescriptor<ExpenseModel>()

        guard let allExpenses = try? context.fetch(descriptor) else { return }
        
        for exp in allExpenses {

            guard exp.seriesId == expense.seriesId else { continue }

            if exp.frequency == expense.frequency {
                // 🔑 Scope handling
                if expense.frequency == .oneTime {
                    if exp.month != expense.month || exp.year != expense.year {
                        continue
                    }
                }
                
                // ✅ SAFE to update (series-level fields only)
                exp.name = expense.name
                exp.amount = expense.amount
                exp.type = expense.type
                exp.frequency = expense.frequency
            }
            // ❌ DO NOT TOUCH exp.month / exp.year
        }
    }



    // MARK: - Delete
    func handleDelete(_ expense: ExpenseModel) {

        let descriptor = FetchDescriptor<ExpenseModel>()
        guard let allExpenses = try? context.fetch(descriptor) else { return }

        for exp in allExpenses {

            guard exp.seriesId == expense.seriesId else { continue }

            if exp.frequency == expense.frequency {

                if expense.frequency == .oneTime {
                    if exp.month != expense.month || exp.year != expense.year {
                        continue
                    }
                }

                context.delete(exp)
            }
        }
    }
    
    // MARK: - Copy helper
    func makeCopy(
        from expense: ExpenseModel,
        month: Int,
        year: Int,
        seriesId: UUID
    ) -> ExpenseModel {

        ExpenseModel(
            seriesId: seriesId,
            name: expense.name,
            amount: expense.amount,
            type: expense.type,
            frequency: expense.frequency,
            month: month,
            year: year,
            isPaid: false,
            paidDate: nil
        )
    }
}
