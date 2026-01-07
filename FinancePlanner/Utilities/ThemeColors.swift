//
//  ThemeColors.swift
//  FinancePlanner
//
//  Created by Saurabh on 07/01/26.
//

import SwiftUI

struct ThemeColors {
    // MARK: - Trading UI Theme with iOS System Background
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let cardBorder = Color(UIColor.separator)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // Accent colors
    static let positive = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let negative = Color(red: 0.95, green: 0.3, blue: 0.2)
    static let accent = Color(red: 0.2, green: 0.4, blue: 0.95)
    static let accentPurple = Color(red: 0.5, green: 0.2, blue: 1)
    
    // Button states
    static let buttonBackground = Color(UIColor.tertiarySystemBackground)
    static let buttonBorder = Color(UIColor.separator).opacity(0.5)
    static let buttonHover = Color(UIColor.quaternarySystemFill)
}

struct ThemeGradients {
    static let positiveGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.2, green: 0.8, blue: 0.4),
            Color(red: 0.15, green: 0.7, blue: 0.35)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 1),
            Color(red: 0.6, green: 0.3, blue: 1)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(UIColor.secondarySystemBackground),
            Color(UIColor.systemBackground)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
