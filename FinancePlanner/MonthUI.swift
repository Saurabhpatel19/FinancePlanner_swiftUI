//
//  MonthUI.swift
//  FinancePlanner
//
//  Created by Saurabh on 30/12/25.
//


import Foundation

struct MonthUI: Identifiable, Equatable {
    let id = UUID()
    let month: Int       // 1...12
    let year: Int
    let title: String
    let shortTitle: String

    static func generate() -> [MonthUI] {
        let calendar = Calendar.current
        let now = Date()

        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "MMMM yyyy"

        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "MMM yy"

        var months: [MonthUI] = []

        // Current year: current month → December
        for month in currentMonth...12 {
            if let date = calendar.date(
                from: DateComponents(year: currentYear, month: month)
            ) {
                months.append(
                    MonthUI(
                        month: month,
                        year: currentYear,
                        title: fullFormatter.string(from: date),
                        shortTitle: shortFormatter.string(from: date)
                    )
                )
            }
        }
        
        for month in 1...12 {
            if let date = calendar.date(
                from: DateComponents(year: currentYear + 1, month: month)
            ) {
                months.append(
                    MonthUI(
                        month: month,
                        year: currentYear + 1,
                        title: fullFormatter.string(from: date),
                        shortTitle: shortFormatter.string(from: date)
                    )
                )
            }
        }

        // If October or later → show next year
        if currentMonth >= 10 {
            let nextYear = currentYear + 2
            for month in 1...12 {
                if let date = calendar.date(
                    from: DateComponents(year: nextYear, month: month)
                ) {
                    months.append(
                        MonthUI(
                            month: month,
                            year: nextYear,
                            title: fullFormatter.string(from: date),
                            shortTitle: shortFormatter.string(from: date)
                        )
                    )
                }
            }
        }

        return months
    }
}
