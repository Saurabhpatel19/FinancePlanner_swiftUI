//
//  PaymentMethod.swift
//  FinancePlanner
//
//  Created by Saurabh on 02/01/26.
//

enum PaymentMethod: String, Codable, CaseIterable {
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case cash = "Cash"
}
