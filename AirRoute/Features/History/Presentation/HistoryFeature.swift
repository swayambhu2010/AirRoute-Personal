//
//  HistoryFeature.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 22/03/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HistoryFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var bookings: [BookingResult] = []
        var selectedYear: Int
        var selectedMonth: Int
        var isLoading = false
        var errorMessage: String? = nil

        init(date: Date = Date()) {
            let c = Calendar.current.dateComponents([.year, .month], from: date)
            selectedYear  = c.year  ?? 2026
            selectedMonth = c.month ?? 1
        }

        var totalCount: Int { bookings.count }
        var totalPrice: Double { bookings.reduce(0) { $0 + $1.price } }
        var formattedTotalPrice: String { CurrencyFormatter.format(totalPrice) }
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case historyFetched([BookingResult])
        case fetchFailed(String)
        case cellTapped(BookingResult)
        case dismissTapped
        case errorDismissed
    }

    // MARK: - Dependencies
    @Dependency(\.historyClient) var historyClient

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                state.isLoading = true
                return .run { [year = state.selectedYear, month = state.selectedMonth] send in
                    do {
                        let results = try await historyClient.fetchHistory(year, month)
                        await send(.historyFetched(results))
                    } catch {
                        await send(.fetchFailed(error.localizedDescription))
                    }
                }

            case .historyFetched(let results):
                state.bookings = results
                state.isLoading = false
                return .none

            case .fetchFailed(let message):
                state.errorMessage = message
                state.isLoading = false
                return .none

            case .cellTapped:
                // Navigation handled in HistoryScreen directly
                return .none

            case .dismissTapped:
                // Navigation handled in HistoryScreen directly
                return .none

            case .errorDismissed:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
