//
//  MapViewModel.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import CoreLocation
import Combine
import SharedModels

@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - State
    @Published private(set) var state = MapState()

    // MARK: - Dependencies
    private let fetchLocationInfoUseCase: FetchLocationInfoUseCaseProtocol
    private let fetchAQIUseCase: FetchAQIUseCaseProtocol
    private let debouncer = Debouncer(delay: 0.5)

    // MARK: - Navigation Callbacks
    private let onLabelTapped: (LocationType) -> Void
    private let onBookTapped: (LocationPoint, LocationPoint) -> Void

    // MARK: - Init
    init(
        fetchLocationInfoUseCase: FetchLocationInfoUseCaseProtocol,
        fetchAQIUseCase: FetchAQIUseCaseProtocol,
        onLabelTapped: @escaping (LocationType) -> Void,
        onBookTapped: @escaping (LocationPoint, LocationPoint) -> Void
    ) {
        self.fetchLocationInfoUseCase = fetchLocationInfoUseCase
        self.fetchAQIUseCase = fetchAQIUseCase
        self.onLabelTapped = onLabelTapped
        self.onBookTapped = onBookTapped
    }

    // MARK: - Send
    func send(_ action: MapAction) {
        switch action {

        // MARK: Lifecycle
        case .onAppear:
            // Initial location handled by
            // .initialLocationReceived via LocationManager
            break

        case .onResume:
            // Returning from Screen 2
            // Refresh AQI for current pin position ✅
            guard let center = state.mapCenter else { return }
            fetchAQI(for: center)

        // MARK: Map — Initial GPS
        case .initialLocationReceived(let coordinate):
            // One-shot — only accept FIRST real GPS
            // LocationManager may publish multiple times
            guard !state.hasReceivedInitialLocation else { return }

            // Store as permanent GPS anchor
            // Survives all resets ✅
            state.currentGPSLocation = coordinate
            state.hasReceivedInitialLocation = true
            state.mapCenter = coordinate

            // Fetch address + AQI for initial position
            fetchLocationInfo(for: coordinate)

        // MARK: Map — Drag Started
        case .mapDragStarted:
            // User finger on screen
            // Pin lifts via PinOverlayView animation ✅
            state.isDragging = true

        // MARK: Map — Camera Idle
        case .mapCameraIdle(let coordinate):
            // Map fully settled
            // Pin tip points at this coordinate ✅
            state.isDragging = false
            state.mapCenter = coordinate

            // Debounce AQI — don't spam API while dragging
            // Fires 0.5s after map stops moving
            debouncer.debounce {
                self.fetchAQI(for: coordinate)
            }

        // MARK: V Button
        case .vButtonTapped:
            guard let center = state.mapCenter else { return }

            // Book state → navigate to Screen 3
            if state.buttonState == .book {
                guard
                    let a = state.locationA,
                    let b = state.locationB
                else { return }
                debouncer.cancel()
                onBookTapped(a, b)
                return
            }

            // Set A or Set B
            // Fetch address + AQI for pin position
            setLocation(for: center)

        // MARK: Labels
        case .labelTapped(let type):
            // Filled → Screen 2 (location detail)
            // Empty  → Screen 5 (saved locations)
            // Decision made in AppRouter ✅
            onLabelTapped(type)

        // MARK: Internal Results
        case .locationInfoFetched(let locationPoint):
            // Initial position info received
            // Update AQI badge ✅
            state.currentAQI = locationPoint.aqi
            state.isLoading = false

        case .aqiFetched(let aqi):
            // Live AQI received
            // Update badge ✅
            state.currentAQI = aqi
            state.isLoading = false

        case .locationSet(let locationPoint, let type):
            // V button fetch complete
            // Fill A or B slot ✅
            switch type {
            case .locationA:
                state.locationA = locationPoint
                state.buttonState = .setB
            case .locationB:
                state.locationB = locationPoint
                state.buttonState = .book
            }
            state.isLoading = false

        case .fetchFailed(let error):
            state.isLoading = false
            state.errorMessage = error.localizedDescription

        // MARK: Saved Location Selected
        case .locationSelectedFromSaved(let location, let type):
            // Fill correct slot
            switch type {
            case .locationA:
                state.locationA = location
                // B already set → Book
                // B not set yet → Set B
                state.buttonState = state.locationB == nil
                    ? .setB
                    : .book
            case .locationB:
                state.locationB = location
                // Both slots filled ✅
                state.buttonState = .book
            }

            // Move map to selected location
            // Pin lands exactly on it
            // Visual confirmation ✅
            let savedCoordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            state.mapCenter = savedCoordinate

            // Always fresh AQI for selected location ✅
            fetchAQI(for: savedCoordinate)

        // MARK: History Preload
        case .preloadFromHistory(let a, let b):
            // Pre-fill A and B from history cell tap
            state.locationA = a
            state.locationB = b
            state.buttonState = .book

            // Move map to location A
            // User sees where the trip starts ✅
            let historyCoordinate = CLLocationCoordinate2D(
                latitude: a.latitude,
                longitude: a.longitude
            )
            state.mapCenter = historyCoordinate

            // Re-fetch AQI — may have changed since history ✅
            fetchAQI(for: historyCoordinate)

        // MARK: Nickname Updated
        case .locationUpdated(let location, let type):
            // Screen 2 saved a nickname
            // Update label on Screen 1 immediately ✅
            switch type {
            case .locationA: state.locationA = location
            case .locationB: state.locationB = location
            }

        // MARK: Reset
        case .resetState:
            // Back button from Screen 3 (booking)
            // Full state reset
            // Map returns to current GPS location ✅
            // Matches TADA / Grab / Uber behaviour ✅
            debouncer.cancel()

            // Save GPS anchor before wipe
            // This NEVER resets — it's permanent ✅
            let gpsLocation = state.currentGPSLocation

            // Full wipe
            state = MapState()

            // Restore permanent GPS anchor
            state.currentGPSLocation = gpsLocation

            // Return map to GPS location
            if let gps = gpsLocation {
                state.mapCenter = gps
                state.hasReceivedInitialLocation = true
                // Fresh AQI for GPS location ✅
                fetchAQI(for: gps)
            }

        // MARK: Error
        case .errorDismissed:
            state.errorMessage = nil
        }
    }

    // MARK: - Private

    // Full fetch — address + AQI
    // Called on initial GPS arrival
    // and V button tap
    private func fetchLocationInfo(
        for coordinate: CLLocationCoordinate2D
    ) {
        state.isLoading = true
        Task {
            do {
                let locationPoint = try await fetchLocationInfoUseCase
                    .execute(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                send(.locationInfoFetched(locationPoint))
            } catch {
                send(.fetchFailed(error))
            }
        }
    }

    // AQI only — never cached, always fresh
    // Called on every camera idle (debounced 0.5s)
    // Silent failure — non-critical
    private func fetchAQI(
        for coordinate: CLLocationCoordinate2D
    ) {
        Task {
            do {
                let aqi = try await fetchAQIUseCase
                    .execute(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                send(.aqiFetched(aqi))
            } catch {
                // Non-critical — keep existing AQI value
                // Don't show error to user
                print("⚠️ AQI fetch failed silently: \(error)")
            }
        }
    }

    // Set A or B — fetch address + AQI for pin position
    // Called when V button tapped in setA or setB state
    private func setLocation(
        for coordinate: CLLocationCoordinate2D
    ) {
        state.isLoading = true
        let type: LocationType = state.buttonState == .setA
            ? .locationA
            : .locationB

        Task {
            do {
                let locationPoint = try await fetchLocationInfoUseCase
                    .execute(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                send(.locationSet(locationPoint, type))
            } catch {
                send(.fetchFailed(error))
            }
        }
    }
}
