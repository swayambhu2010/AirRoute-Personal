//
//  BookingViewModel.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import Combine

@MainActor
final class BookingViewModel: ObservableObject {
    
    // MARK: - State
    @Published private(set) var state = BookingState()
    
    // MARK: - Dependencies
    private let bookRideUseCase: BookRideUseCaseProtocol
    
    // MARK: - Navigation Callbacks
    private let onGoToHistory: () -> Void
    private let onDismiss: () -> Void
    
    // MARK: - Init
    init(
        locationA: LocationPoint,
        locationB: LocationPoint,
        bookRideUseCase: BookRideUseCaseProtocol,
        onGoToHistory: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.bookRideUseCase = bookRideUseCase
        self.onGoToHistory = onGoToHistory
        self.onDismiss = onDismiss
        self.state.locationA = locationA
        self.state.locationB = locationB
    }
    
    // MARK: - Send
    func send(_ action: BookingAction) {
        switch action {
            
        case .onAppear:
            // Lifecycle only
            // Guard: don't re-book if already loading or succeeded
            guard
                state.bookingResult == nil,
                !state.isLoading
            else { return }
            // Explicit, intentional trigger
            send(.startBooking)
            
        case .startBooking:
            bookRide()
            
        case .goToHistoryTapped:
            onGoToHistory()
            
        case .dismissTapped:
            // Back → resets Screen 1
            onDismiss()
            
        case .bookingSucceeded(let result):
            state.bookingResult = result
            state.isLoading = false
            
        case .bookingFailed(let error):
            state.errorMessage = error.localizedDescription
            state.isLoading = false
            
        case .errorDismissed:
            state.errorMessage = nil
        }
    }
    
    // MARK: - Private
    private func bookRide() {
        guard
            let a = state.locationA,
            let b = state.locationB
        else { return }
        
        state.isLoading = true
        
        Task {
            do {
                let result = try await bookRideUseCase
                    .execute(a: a, b: b)
                send(.bookingSucceeded(result))
            } catch {
                send(.bookingFailed(error))
            }
        }
    }
}
