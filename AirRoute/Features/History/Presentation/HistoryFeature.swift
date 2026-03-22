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
    // Identical to your HistoryState — just nested
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
    // Identical to your HistoryAction — just nested
    enum Action {
        case onAppear
        case historyFetched([BookingResult])
        case fetchFailed(Error)
        case cellTapped(BookingResult)
        case dismissTapped
        case errorDismissed
    }

    // MARK: - Dependencies
    // Replaces constructor injection
    @Dependency(\.historyClient) var historyClient

    // MARK: - Navigation callbacks
    // Same pattern as your current closures
    var onLocationSelected: (LocationPoint, LocationPoint) -> Void = { _, _ in }
    var onDismiss: () -> Void = {}

    // MARK: - Reducer
    // Replaces your send() switch statement
    // KEY DIFFERENCE: returns Effect instead of starting Task internally
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                state.isLoading = true
                // .run replaces Task { } inside send()
                // The store runs this for you and can cancel it
                return .run { [year = state.selectedYear, month = state.selectedMonth] send in
                    do {
                        let results = try await historyClient.fetchHistory(year, month)
                        await send(.historyFetched(results))
                    } catch {
                        await send(.fetchFailed(error))
                    }
                }

            case .historyFetched(let results):
                state.bookings = results
                state.isLoading = false
                return .none   // no side effect needed

            case .fetchFailed(let error):
                state.errorMessage = error.localizedDescription
                state.isLoading = false
                return .none

            case .cellTapped(let booking):
                onLocationSelected(booking.locationA, booking.locationB)
                return .none

            case .dismissTapped:
                onDismiss()
                return .none

            case .errorDismissed:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
