//
//  PreviewFactory.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import CoreLocation

// MARK: - PreviewFactory
// Creates ViewModels with mock dependencies
// Used ONLY in #Preview blocks
// Never in production code
@MainActor
enum PreviewFactory {

    // MARK: - DIContainer
    // Mock container — no real network calls
    private static let container = DIContainer()

    // MARK: - MapViewModel
    static func makeMapViewModel() -> MapViewModel {
        let fetchLocationInfoUseCase = FetchLocationInfoUseCase(
            repository: container.locationRepository
        )
        let fetchAQIUseCase = FetchAQIUseCase(
            repository: container.locationRepository
        )
        return MapViewModel(
            fetchLocationInfoUseCase: fetchLocationInfoUseCase,
            fetchAQIUseCase: fetchAQIUseCase,
            onLabelTapped: { _ in },
            onBookTapped: { _, _ in }
        )
    }

    // MARK: - LocationDetailViewModel
    static func makeLocationDetailViewModel(
        type: LocationType = .locationA
    ) -> LocationDetailViewModel {
        let fetchCachedLocationUseCase = FetchCachedLocationUseCase(
            repository: container.locationRepository
        )
        let updateNicknameUseCase = UpdateNicknameUseCase(
            repository: container.locationRepository
        )
        return LocationDetailViewModel(
            location: LocationPoint(
                latitude: 37.5642,
                longitude: 127.0016,
                aqi: 32,
                name: "Seoul City Hall",
                nickname: nil
            ),
            locationType: type,
            fetchCachedLocationUseCase: fetchCachedLocationUseCase,
            updateNicknameUseCase: updateNicknameUseCase,
            onNicknameSaved: { _ in },
            onDismiss: {}
        )
    }

    // MARK: - BookingViewModel
    static func makeBookingViewModel() -> BookingViewModel {
        let bookRideUseCase = BookRideUseCase(
            repository: container.bookingRepository
        )
        return BookingViewModel(
            locationA: LocationPoint(
                latitude: 37.5642,
                longitude: 127.0016,
                aqi: 32,
                name: "Seoul City Hall",
                nickname: nil
            ),
            locationB: LocationPoint(
                latitude: 37.5700,
                longitude: 127.0100,
                aqi: 45,
                name: "Gangnam Station",
                nickname: nil
            ),
            bookRideUseCase: bookRideUseCase,
            onGoToHistory: {},
            onDismiss: {}
        )
    }

    // MARK: - HistoryViewModel
   /* static func makeHistoryViewModel() -> HistoryViewModel {
        let fetchHistoryUseCase = FetchHistoryUseCase(
            repository: container.historyRepository
        )
        return HistoryViewModel(
            fetchHistoryUseCase: fetchHistoryUseCase,
            onLocationSelected: { _, _ in },
            onDismiss: {}
        )
    }*/

    // MARK: - SavedLocationsViewModel
    static func makeSavedLocationsViewModel(
        selectingFor type: LocationType = .locationA
    ) -> SavedLocationsViewModel {
        let fetchSavedLocationsUseCase = FetchSavedLocationsUseCase(
            repository: container.savedLocationsRepository
        )
        return SavedLocationsViewModel(
            selectingFor: type,
            fetchSavedLocationsUseCase: fetchSavedLocationsUseCase,
            onLocationSelected: { _, _ in },
            onDismiss: {}
        )
    }
}
