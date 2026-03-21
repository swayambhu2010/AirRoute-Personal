//
//  HistoryState.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

struct HistoryState {

    // MARK: - Data
    var bookings: [BookingResult] = []

    // MARK: - Filter
    // Computed ONCE from a single Date snapshot
    // No duplication, no midnight race condition
    public var selectedYear: Int
    public var selectedMonth: Int

    // MARK: - Loading
    var isLoading: Bool = false

    // MARK: - Error
    var errorMessage: String? = nil

    // MARK: - Init
    // Date injected — makes State testable
    // Pass Date() for production
    // Pass a fixed date in tests
    init(date: Date = Date()) {
        let components = Calendar.current.dateComponents(
            [.year, .month],
            from: date
        )
        self.selectedYear = components.year ?? 2026
        self.selectedMonth = components.month ?? 1
    }

    // MARK: - Computed
    var totalCount: Int { bookings.count }

    var totalPrice: Double {
        bookings.reduce(0) { $0 + $1.price }
    }

    var formattedTotalPrice: String {
        CurrencyFormatter.format(totalPrice)
    }
}
