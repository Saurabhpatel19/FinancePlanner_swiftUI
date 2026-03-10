import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case housing
    case utilities
    case groceries
    case transport
    case health
    case education
    case entertainment
    case insurance
    case emi
    case subscriptions
    case travel
    case shopping
    case other

    var id: Self { self }

    var displayTitle: String {
        switch self {
        case .housing: return "Housing"
        case .utilities: return "Utilities"
        case .groceries: return "Groceries"
        case .transport: return "Transport"
        case .health: return "Health"
        case .education: return "Education"
        case .entertainment: return "Entertainment"
        case .insurance: return "Insurance"
        case .emi: return "EMI"
        case .subscriptions: return "Subscriptions"
        case .travel: return "Travel"
        case .shopping: return "Shopping"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .groceries: return "cart.fill"
        case .transport: return "car.fill"
        case .health: return "cross.case.fill"
        case .education: return "book.fill"
        case .entertainment: return "tv.fill"
        case .insurance: return "shield.fill"
        case .emi: return "creditcard.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .travel: return "airplane"
        case .shopping: return "bag.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}
