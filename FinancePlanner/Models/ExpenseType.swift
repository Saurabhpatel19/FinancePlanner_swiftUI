//
//  ExpenseType.swift
//  FinancePlanner
//
//  Created by Saurabh on 02/01/26.
//


enum ExpenseType: String, Codable, CaseIterable, Identifiable {
    case fixed
    case variable

    var id: Self { self }

    var displayTitle: String {
        switch self {
        case .fixed:
            return "Fixed"
        case .variable:
            return "Variable"
        }
    }
}