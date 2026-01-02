 //
 //  ExpenseType.swift
 //  FinancePlanner
 //
 //  Created by Saurabh on 25/12/25.
 //


 import Foundation
 import SwiftData

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
     
     // MARK: - Due / ECS
     /// Day of month (1–31), same for all recurring instances
     var dueDay: Int?

     // MARK: - Payment Status (HOME ONLY)
     /// Controlled only from Home checkbox
     var isPaid: Bool

     // MARK: - Payment Details (Optional Metadata)
     /// Actual payment date
     var paymentDate: Date?

     /// How it was paid (Card / Bank / Cash)
     var paymentMethod: PaymentMethod?

     /// From where (SBI, ICICI CC, Cash, etc.)
     var paymentSource: String?

     // MARK: - Notes (Independent)
     /// Free-text notes for reconciliation / context
     var note: String?

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
         dueDay: Int? = nil,
         isPaid: Bool = false,
         paymentDate: Date? = nil,
         paymentMethod: PaymentMethod? = nil,
         paymentSource: String? = nil,
         note: String? = nil,
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
         self.dueDay = dueDay
         self.isPaid = isPaid
         self.paymentDate = paymentDate
         self.paymentMethod = paymentMethod
         self.paymentSource = paymentSource
         self.note = note
     }
 }


 // MARK: - Paid Logic (FINAL)
 extension ExpenseModel {

     func togglePaid() {
         if isPaid {
             // MARK: - Unmark Paid
             isPaid = false
             paymentDate = nil
             paymentMethod = nil
             paymentSource = nil
         } else {
             // MARK: - Mark Paid
             isPaid = true
             // ⚠️ Do NOT set paymentDate here
             // Payment details are added via bottom sheet (optional)
         }
     }
     
     // Monthly (Home)
     func togglePaid(forMonth month: Int, year: Int) {
         guard self.month == month, self.year == year else { return }

         if isPaid {
             // MARK: - Unmark Paid
             isPaid = false
             paymentDate = nil
             paymentMethod = nil
             paymentSource = nil
         } else {
             // MARK: - Mark Paid
             isPaid = true
             // ⚠️ Do NOT set paymentDate here
             // Payment details are added via bottom sheet (optional)
         }
     }

     func togglePaid(year: Int) {
         guard self.year == year else { return }

         if isPaid {
             // MARK: - Unmark Paid
             isPaid = false
             paymentDate = nil
             paymentMethod = nil
             paymentSource = nil
         } else {
             // MARK: - Mark Paid
             isPaid = true
             // ⚠️ Do NOT set paymentDate here
             // Payment details are added via bottom sheet (optional)
         }
     }
 }
