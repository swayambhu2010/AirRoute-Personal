//
//  AppRouter.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    
    // MARK: - Navigation Path
    @Published var path = NavigationPath()
    
    // MARK: - DI Container
    private let container: DIContainer
    
    // MARK: - MapViewModel Reference
    // Kept so AppRouter can send
    // .preloadFromHistory and
    // .locationSelectedFromSaved actions
    // back to Screen 1
    private var mapViewModel: MapViewModel?
    
    private(set) lazy var mapScreen: MapScreen = {
        makeMapScreen()
    }()
    
    // MARK: - Init
    init(container: DIContainer) {
        self.container = container
    }
    
    // MARK: - Navigation
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // MARK: - View Factory
    
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .locationDetail(let location, let type):
            makeLocationDetailScreen(
                location: location,
                type: type
            )
        case .bookingConfirmation(let a, let b):
            makeBookingScreen(a: a, b: b)
        case .history:
            makeHistoryScreen()
        case .savedLocations(let type):
            makeSavedLocationsScreen(selectingFor: type)
        }
    }
    
    // MARK: - Screen Factories
    
    // MARK: Screen 1
    private func makeMapScreen() -> MapScreen {
        let viewModel = MapViewModel(
            fetchLocationInfoUseCase: FetchLocationInfoUseCase(
                repository: container.locationRepository
            ),
            fetchAQIUseCase: FetchAQIUseCase(
                repository: container.locationRepository
            ),
            onLabelTapped: { [weak self] type in
                guard let self,
                      let vm = self.mapViewModel
                else { return }
                
                switch type {
                case .locationA:
                    // MUST check locationA directly
                    // NOT isALabelEmpty computed property
                    if let location = vm.state.locationA {
                        // Filled → Screen 2
                        self.navigate(to: .locationDetail(
                            location: location,
                            type: .locationA
                        ))
                    } else {
                        // Empty → Screen 5
                        self.navigate(to: .savedLocations(
                            selectingFor: .locationA
                        ))
                    }
                    
                case .locationB:
                    if let location = vm.state.locationB {
                        // Filled → Screen 2
                        self.navigate(to: .locationDetail(
                            location: location,
                            type: .locationB
                        ))
                    } else {
                        // Empty → Screen 5
                        self.navigate(to: .savedLocations(
                            selectingFor: .locationB
                        ))
                    }
                }
            },
            onBookTapped: { [weak self] a, b in
                self?.navigate(to: .bookingConfirmation(
                    a: a,
                    b: b
                ))
            }
        )
        
        // Keep weak reference to MapViewModel
        // so we can send actions back to it later
        self.mapViewModel = viewModel
        
        return MapScreen(viewModel: viewModel)
    }
    
    // MARK: Screen 2
    private func makeLocationDetailScreen(
        location: LocationPoint,
        type: LocationType
    ) -> LocationDetailScreen {
        let viewModel = LocationDetailViewModel(
            location: location,
            locationType: type,
            fetchCachedLocationUseCase: FetchCachedLocationUseCase(
                repository: container.locationRepository
            ),
            updateNicknameUseCase: UpdateNicknameUseCase(
                repository: container.locationRepository
            ),
            // Called when V tapped on Screen 2
            // Updated location (with nickname)
            // sent back to Screen 1 MapViewModel
            onNicknameSaved: { [weak self] updatedLocation in
                self?.mapViewModel?.send(
                    .locationUpdated(updatedLocation, type)
                )
            },
            onDismiss: { [weak self] in
                self?.pop()
            }
        )
        return LocationDetailScreen(viewModel: viewModel)
    }
    
    // MARK: Screen 3
    private func makeBookingScreen(
        a: LocationPoint,
        b: LocationPoint
    ) -> BookingScreen {
        let viewModel = BookingViewModel(
            locationA: a,
            locationB: b,
            bookRideUseCase: BookRideUseCase(
                repository: container.bookingRepository
            ),
            onGoToHistory: { [weak self] in
                self?.navigate(to: .history)
            },
            onDismiss: { [weak self] in
                // Back → pop to root
                // Reset Screen 1 state
                self?.popToRoot()
                self?.mapViewModel?.send(.resetState)
            }
        )
        return BookingScreen(viewModel: viewModel)
    }
    
    // MARK: Screen 4
    private func makeHistoryScreen() -> HistoryScreen {
        let viewModel = HistoryViewModel(
            fetchHistoryUseCase: FetchHistoryUseCase(
                repository: container.historyRepository
            ),
            onLocationSelected: { [weak self] a, b in
                // Pop to root → Screen 1
                self?.popToRoot()
                // Send preload action to MapViewModel
                // MapViewModel pre-fills A + B
                // sets button to Book
                // re-fetches AQI
                self?.mapViewModel?.send(
                    .preloadFromHistory(a: a, b: b)
                )
            },
            onDismiss: { [weak self] in
                self?.pop()
            }
        )
        return HistoryScreen(viewModel: viewModel)
    }
    
    // MARK: Screen 5
    private func makeSavedLocationsScreen(
        selectingFor type: LocationType
    ) -> SavedLocationsScreen {
        let viewModel = SavedLocationsViewModel(
            selectingFor: type,
            fetchSavedLocationsUseCase: FetchSavedLocationsUseCase(
                repository: container.savedLocationsRepository
            ),
            onLocationSelected: { [weak self] location, locationType in
                // Pop back to Screen 1
                self?.pop()
                // Send selection to MapViewModel
                // MapViewModel sets A or B
                self?.mapViewModel?.send(
                    .locationSelectedFromSaved(
                        location,
                        locationType
                    )
                )
            },
            onDismiss: { [weak self] in
                // Back → pop + reset Screen 1
                self?.pop()
                self?.mapViewModel?.send(.resetState)
            }
        )
        return SavedLocationsScreen(viewModel: viewModel)
    }
}
