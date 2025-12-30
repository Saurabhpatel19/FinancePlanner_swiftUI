//
//  MonthStatus.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import Foundation
import SwiftData

enum MonthStatus: String, Codable {
    case draft
    case finalized
}

@Model
class MonthModel {

    var id: UUID
    var title: String
    var status: MonthStatus

    var fixedExpenses: [ExpenseModel]
    var variableExpenses: [ExpenseModel]
    var checklist: [ChecklistItem]

    init(
        id: UUID = UUID(),
        title: String,
        status: MonthStatus,
        fixedExpenses: [ExpenseModel],
        variableExpenses: [ExpenseModel],
        checklist: [ChecklistItem] = []
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.fixedExpenses = fixedExpenses
        self.variableExpenses = variableExpenses
        self.checklist = checklist
    }
}
