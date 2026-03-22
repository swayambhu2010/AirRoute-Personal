//
//  SavedLocationsViewModel.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import Combine
import SharedModels

@MainActor
final class SavedLocationsViewModel: ObservableObject {

    // MARK: - State
    @Published private(set) var state = SavedLocationsState()

    // MARK: - Dependencies
    private let fetchSavedLocationsUseCase: FetchSavedLocationsUseCaseProtocol

    // MARK: - Context
    private let selectingFor: LocationType

    // MARK: - Navigation Callbacks
    private let onLocationSelected: (LocationPoint, LocationType) -> Void
    private let onDismiss: () -> Void

    // MARK: - Init
    init(
        selectingFor: LocationType,
        fetchSavedLocationsUseCase: FetchSavedLocationsUseCaseProtocol,
        onLocationSelected: @escaping (LocationPoint, LocationType) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.selectingFor = selectingFor
        self.fetchSavedLocationsUseCase = fetchSavedLocationsUseCase
        self.onLocationSelected = onLocationSelected
        self.onDismiss = onDismiss
        self.state.selectingFor = selectingFor
    }

    // MARK: - Send
    func send(_ action: SavedLocationsAction) {
        switch action {

        case .onAppear:
            loadLocations()

        case .locationTapped(let location):
            // Pass selected location + slot back to Screen 1
            // Screen 1 updates A or B
            // then updates button state ✅
            onLocationSelected(location, selectingFor)

        case .dismissTapped:
            // Back → AppRouter pops to Screen 1
            // Screen 1 resets to initial state ✅
            onDismiss()
        }
    }

    // MARK: - Private
    private func loadLocations() {
        state.locations = fetchSavedLocationsUseCase.execute()
    }
}
