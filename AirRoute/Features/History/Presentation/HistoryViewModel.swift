//
//  HistoryViewModel.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    // MARK: - State
    @Published var state = HistoryState()

    // MARK: - Dependencies
    private let fetchHistoryUseCase: FetchHistoryUseCaseProtocol

    // MARK: - Navigation Callbacks
    private let onLocationSelected: (LocationPoint, LocationPoint) -> Void
    private let onDismiss: () -> Void

    // MARK: - Init
    init(
        fetchHistoryUseCase: FetchHistoryUseCaseProtocol,
        onLocationSelected: @escaping (LocationPoint, LocationPoint) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.fetchHistoryUseCase = fetchHistoryUseCase
        self.onLocationSelected = onLocationSelected
        self.onDismiss = onDismiss
    }

    // MARK: - Send
    func send(_ action: HistoryAction) {
        switch action {

        case .onAppear:
            fetchHistory()

        case .historyFetched(let results):
            state.bookings = results
            state.isLoading = false

        case .fetchFailed(let error):
            state.errorMessage = error.localizedDescription
            state.isLoading = false

        case .cellTapped(let booking):
            // Pre-fill Screen 1 A + B
            // → sets locationA + locationB
            // → buttonState = .book ✅
            // → re-fetches AQI ✅
            onLocationSelected(
                booking.locationA,
                booking.locationB
            )

        case .dismissTapped:
            onDismiss()

        case .errorDismissed:
            state.errorMessage = nil
        }
    }

    // MARK: - Private
    private func fetchHistory() {
        state.isLoading = true
        Task {
            do {
                let results = try await fetchHistoryUseCase
                    .execute(
                        year: state.selectedYear,
                        month: state.selectedMonth
                    )
                send(.historyFetched(results))
            } catch {
                send(.fetchFailed(error))
            }
        }
    }
}
