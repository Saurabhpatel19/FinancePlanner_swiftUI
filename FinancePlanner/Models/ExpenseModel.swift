 //
 //  ExpenseType.swift
 //  FinancePlanner
 //
 //  Created by Saurabh on 25/12/25.
 //


 import Foundation
 import SwiftData

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


 enum ExpenseFrequency: String, Codable, CaseIterable, Identifiable {
     case oneTime
     case monthly
     case yearly

     var id: Self { self }

     // Display text for UI
     var displayTitle: String {
         switch self {
         case .oneTime:
             return "Once"
         case .monthly:
             return "Monthly"
         case .yearly:
             return "Yearly"
         }
     }
 }

 extension ExpenseFrequency {
     var affectsFutureMonths: Bool {
         self == .monthly
     }
 }

 @Model
 class ExpenseModel {

     var id: UUID
     var seriesId: UUID

     var name: String
     var amount: Double
     var type: ExpenseType
     var frequency: ExpenseFrequency

     // ✅ NEW (SOURCE OF TRUTH)
     var month: Int        // 1...12
     var year: Int         // 2025, 2026, etc

     // 🔹 Recurrence boundary (monthly only)
     var startMonth: Int?
     var startYear: Int?
     
     // 🔹 Recurrence boundary (monthly only)
     var endMonth: Int?
     var endYear: Int?
     
     // Payment state
     var isPaid: Bool
     
     // Payment
     var paidDate: Date?

     init(
         id: UUID = UUID(),
         seriesId: UUID = UUID(),
         name: String,
         amount: Double,
         type: ExpenseType,
         frequency: ExpenseFrequency,
         month: Int,
         year: Int,
         startMonth: Int? = nil,
         startYear: Int? = nil,
         endMonth: Int? = nil,
         endYear: Int? = nil,
         isPaid: Bool = false,
         paidDate: Date? = nil
     ) {
         self.id = id
         self.seriesId = seriesId
         self.name = name
         self.amount = amount
         self.type = type
         self.frequency = frequency
         self.month = month
         self.year = year
         self.startMonth = startMonth
         self.startYear = startYear
         self.endMonth = endMonth
         self.endYear = endYear
         self.isPaid = isPaid
         self.paidDate = paidDate
     }
 }


 // MARK: - Paid Logic (FINAL)
 extension ExpenseModel {

     // Monthly (Home)
     func togglePaid(forMonth month: Int, year: Int) {
         guard self.month == month, self.year == year else { return }

         isPaid.toggle()

         if isPaid {
             paidDate = Date()
         } else {
             paidDate = nil
         }
     }

     func togglePaid(year: Int) {
         guard self.year == year else { return }

         isPaid.toggle()

         if isPaid {
             paidDate = Date()
         } else {
             paidDate = nil
         }
     }
 }
