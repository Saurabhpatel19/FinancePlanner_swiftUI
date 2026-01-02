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
    func expenseUnified(expense: ExpenseModel, actionType: ExpenseActionType) {
        switch actionType {

        case .add:
            handleAdd(expense)

        case .update:
            if expense.frequency == .monthly {
                rebuildMonthlySeries(expense: expense)
            } else {
                handleUpdate(expense)
            }

        case .delete:
            handleDelete(expense)
        }

        try? context.save()
    }
    
    /*
    func optOutRecurringOccurrence(expense: ExpenseModel, month: Int, year: Int) {
        let descriptor = FetchDescriptor<ExpenseModel>()
        guard let allExpenses = try? context.fetch(descriptor) else { return }

        // 1️⃣ Find the monthly occurrence to remove
        guard let monthlyInstance = allExpenses.first(where: {
            $0.seriesId == expense.seriesId &&
            $0.frequency == .monthly &&
            $0.month == month &&
            $0.year == year
        }) else {
            return
        }

        // 2️⃣ Create new oneTime expense with NEW seriesId
        let oneTime = ExpenseModel(
            seriesId: UUID(),                 // 🔑 NEW series
            name: monthlyInstance.name,
            amount: monthlyInstance.amount,
            type: monthlyInstance.type,
            frequency: .oneTime,
            month: month,
            year: year,
            startMonth: nil,
            startYear: nil,
            isPaid: monthlyInstance.isPaid,
            paidDate: monthlyInstance.paidDate
        )

        context.insert(oneTime)

        // 3️⃣ Remove monthly instance
        context.delete(monthlyInstance)

        try? context.save()
    }
    */
    
}

private extension FinanceDataService {

    // MARK: - Add
    func handleAdd(_ expense: ExpenseModel,paidSnapshot: [String: (Bool, Date?, PaymentMethod?, String?)] = [:]) {

        let seriesId = expense.seriesId
        let calendar = Calendar.current
        let now = Date()

        // MARK: - Resolve START
        let startMonth: Int
        let startYear: Int

        switch expense.frequency {

        case .oneTime:
            startMonth = expense.month
            startYear = expense.year

        case .monthly:
            guard
                let sMonth = expense.startMonth,
                let sYear = expense.startYear
            else { return }
            startMonth = sMonth
            startYear = sYear

        case .yearly:
            guard let sYear = expense.startYear else { return }
            startMonth = expense.month          // fixed month for yearly
            startYear = sYear
        }

        // MARK: - Resolve END (IMPORTANT FIX)
        let endMonth: Int
        let endYear: Int

        switch expense.frequency {

        case .oneTime:
            endMonth = startMonth
            endYear = startYear

        case .monthly:
            if let eMonth = expense.endMonth,
               let eYear = expense.endYear {
                endMonth = eMonth
                endYear = eYear
            } else {
                let currentYear = calendar.component(.year, from: now)
                endMonth = 12
                endYear = currentYear + 1
            }

        case .yearly:
            if let eYear = expense.endYear {
                endYear = eYear
            } else {
                let currentYear = calendar.component(.year, from: now)
                endYear = currentYear + 1
            }
            endMonth = startMonth   // 🔑 yearly never uses endMonth
        }

        // MARK: - Unified iteration
        var month = startMonth
        var year = startYear
        print("endyear \(endYear)")
        while (year < endYear) || (year == endYear && month <= endMonth) {

            print("inner endyear \(endYear)")
            let copy = makeCopy(
                from: expense,
                seriesId: seriesId,
                month: month,
                year: year,
                startMonth: expense.frequency == .monthly ? startMonth : nil,
                startYear: expense.frequency != .oneTime ? startYear : nil,
                endMonth: expense.frequency == .monthly ? endMonth : nil,
                endYear: expense.frequency != .oneTime ? endYear : nil
            )

            // restore paid state if exists
            let key = "\(expense.year)-\(expense.month)"
            if let snapshot = paidSnapshot[key] {
                copy.isPaid = snapshot.0
                copy.paymentDate = snapshot.1
                copy.paymentMethod = snapshot.2
                copy.paymentSource = snapshot.3
            }
            
            
            context.insert(copy)

            // MARK: - Step
            switch expense.frequency {

            case .oneTime:
                return   // exactly one record

            case .monthly:
                month += 1
                if month > 12 {
                    month = 1
                    year += 1
                }

            case .yearly:
                year += 1   // month stays fixed
            }
        }
    }

    // MARK: - Rebuild Monthly Expense
    func rebuildMonthlySeries(expense: ExpenseModel) {

        let descriptor = FetchDescriptor<ExpenseModel>()
        guard let allExpenses = try? context.fetch(descriptor) else { return }

        // 1️⃣ Existing monthly series
        let oldMonthly = allExpenses.filter {
            $0.seriesId == expense.seriesId &&
            $0.frequency == .monthly
        }

        guard let first = oldMonthly.first,
              let newStartMonth = expense.startMonth,
              let newStartYear = expense.startYear,
              let newEndMonth = expense.endMonth,
              let newEndYear = expense.endYear
        else { return }

        // 2️⃣ If boundary unchanged → series-level update only
        if first.startMonth == newStartMonth,
           first.startYear == newStartYear,
           first.endMonth == newEndMonth,
           first.endYear == newEndYear {

            for exp in oldMonthly {
                exp.name = expense.name
                exp.amount = expense.amount
                exp.type = expense.type
                
                exp.dueDay = expense.dueDay
                exp.note = expense.note
            }

            try? context.save()
            return
        }

        // 3️⃣ Snapshot paid state
        var paidSnapshot: [String: (Bool, Date?, PaymentMethod?, String?)] = [:]
        for exp in oldMonthly {
            let key = "\(exp.year)-\(exp.month)"
            paidSnapshot[key] = (exp.isPaid, exp.paymentDate, exp.paymentMethod, exp.paymentSource)
        }

        // 4️⃣ Delete old monthly series
        for exp in oldMonthly {
            context.delete(exp)
        }

        handleAdd(expense, paidSnapshot: paidSnapshot)
        return
    }

    // MARK: - Update
    func handleUpdate(_ expense: ExpenseModel) {

        let descriptor = FetchDescriptor<ExpenseModel>()
        guard let allExpenses = try? context.fetch(descriptor) else { return }

        for exp in allExpenses {

            guard exp.seriesId == expense.seriesId else { continue }

            // 🔑 oneTime = instance-level update
            if expense.frequency == .oneTime {
                if exp.frequency != .oneTime {
                    continue
                }
                if exp.month != expense.month || exp.year != expense.year {
                    continue
                }
            }

            // 🔑 monthly/yearly = series-level update
            if expense.frequency != .oneTime,
               exp.frequency != expense.frequency {
                continue
            }

            // series-level fields
            exp.name = expense.name
            exp.amount = expense.amount
            exp.type = expense.type
            
            exp.dueDay = expense.dueDay
            exp.note = expense.note
        }
    }

    // MARK: - Delete
    func handleDelete(_ expense: ExpenseModel) {

        let descriptor = FetchDescriptor<ExpenseModel>()
        guard let allExpenses = try? context.fetch(descriptor) else { return }

        for exp in allExpenses {

            guard exp.seriesId == expense.seriesId else { continue }

            // 🔑 oneTime = instance-level delete
            if expense.frequency == .oneTime {
                if exp.frequency != .oneTime { continue }
                if exp.month != expense.month || exp.year != expense.year { continue }
                context.delete(exp)
                continue
            }

            // 🔑 monthly / yearly = series-level delete
            if exp.frequency == expense.frequency {
                context.delete(exp)
            }
        }
    }

    // MARK: - Copy helper
    func makeCopy(
        from expense: ExpenseModel,
        seriesId: UUID,
        month: Int,
        year: Int,
        startMonth: Int? = nil,
        startYear: Int? = nil,
        endMonth: Int? = nil,
        endYear: Int? = nil,
    ) -> ExpenseModel
    {
        ExpenseModel(
            seriesId: seriesId,
            name: expense.name,
            amount: expense.amount,
            type: expense.type,
            frequency: expense.frequency,
            month: month,
            year: year,
            startMonth: startMonth,
            startYear: startYear,
            endMonth: endMonth,
            endYear: endYear,
            dueDay: expense.dueDay,
            isPaid: false,
            note: expense.note,
        )
    }
}
