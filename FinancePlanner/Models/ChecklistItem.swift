//
//  ChecklistItem.swift
//  FinancePlanner
//
//  Created by Saurabh on 25/12/25.
//


import Foundation
import SwiftData

@Model
class ChecklistItem {

    var id: UUID
    var name: String
    var amount: Double
    var isPaid: Bool

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        isPaid: Bool
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.isPaid = isPaid
    }
}

