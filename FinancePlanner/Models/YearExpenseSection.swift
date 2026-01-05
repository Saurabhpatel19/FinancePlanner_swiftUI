//
//  YearExpenseSection.swift
//  FinancePlanner
//
//  Created by Saurabh on 05/01/26.
//

import Foundation

struct YearExpenseSection: Identifiable {
    let id = UUID()
    let year: Int
    let items: [SeriesExpenseSummary]
}

struct SeriesExpenseSummary: Identifiable {
    let id: UUID              // seriesId
    let name: String
    
    let displayTotal: Double     // what we show as main amount
    let monthlyAmount: Double?   // only for .monthly
    
    let frequency: ExpenseFrequency
    let startMonth: Int?
    let startYear: Int?
    let endMonth: Int?
    let endYear: Int?
}
