//
//  DIContainer.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - DIContainer
// Single source of all dependencies
// Server status:
// Location API   → implemented → real network call
// SavedLocations → Mock
// Booking API    → NOT implemented → Mock
// History API    → NOT implemented → Mock

final class DIContainer {
    
    // MARK: - Network
    lazy var networkManager: NetworkRequest = {
        NetworkManager(sessionManager: AlamofireSessionManager())
    }()
    
    // MARK: - Cache
    lazy var locationCache: LocationCacheProtocol = {
        LocationCache()
    }()
    
    // MARK: - Repositories
    
    // MARK: Location — Real Server
    lazy var locationRepository: LocationRepositoryProtocol = {
        LocationRepository(
            networkService: networkManager,
            cache: locationCache
        )
    }()
    
    // MARK: Booking — Mock
    // Server not implemented
    // TODO: when server ready replace with:
    // BookingRepository(networkService: networkManager)
    lazy var bookingRepository: BookingRepositoryProtocol = {
        MockBookingRepository()
    }()
    
    // MARK: History — Mock
    // Server not implemented
    // TODO: when server ready replace with:
    // HistoryRepository(networkService: networkManager)
    lazy var historyRepository: HistoryRepositoryProtocol = {
        MockHistoryRepository()
    }()
    
    // MARK: SavedLocations — Mock
    lazy var savedLocationsRepository: SavedLocationsRepositoryProtocol = {
        MockSavedLocationsRepository()
    }()
}
