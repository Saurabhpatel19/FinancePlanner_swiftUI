//
//  MonthItem.swift
//  FinancePlanner
//
//  Created by Saurabh on 02/01/26.
//

import Foundation

private struct MonthItem: Identifiable, Equatable {
    let id = UUID()
    let month: Int
    let year: Int
}
