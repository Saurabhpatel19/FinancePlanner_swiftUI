//
//  ExpenseFrequency.swift
//  FinancePlanner
//
//  Created by Saurabh on 02/01/26.
//

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

     var affectsFutureMonths: Bool {
         self == .monthly
     }
 }
