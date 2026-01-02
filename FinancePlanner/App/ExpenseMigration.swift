//
//  ExpenseMigration.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftData

struct ExpenseMigration {

    /*
    static func migratePaidState(context: ModelContext) {
        let descriptor = FetchDescriptor<ExpenseModel>()
        
        do {
            let expenses = try context.fetch(descriptor)

            var didChange = false

            for expense in expenses {
                if expense.paidDate != nil {
                    expense.isPaid = true
                    didChange = true
                }
            }

            if didChange {
                try context.save()
                print("✅ Expense paid-state migration completed")
            }
        } catch {
            print("❌ Migration failed:", error)
        }
    }
     */
}
