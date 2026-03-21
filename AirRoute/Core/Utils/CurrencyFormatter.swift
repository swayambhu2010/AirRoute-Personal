//
//  CurrencyFormatter.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 16/03/26.
//

import Foundation

// MARK: - CurrencyFormatter
// Single shared formatter
// Uses device locale automatically
// Korean device → ₩10,000
// US device     → $10,000.00
// Used across Screen 3, Screen 4

enum CurrencyFormatter {

    // MARK: - Shared Formatter
    // Static — created once
    // Reused across all calls
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    // MARK: - Format
    // Returns formatted currency string
    // Falls back to plain number if formatter fails
    static func format(_ value: Double) -> String {
        return formatter.string(
            from: NSNumber(value: value)
        ) ?? "\(value)"
    }
}
