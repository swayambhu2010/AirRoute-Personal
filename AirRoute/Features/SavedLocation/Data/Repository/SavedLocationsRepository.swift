//
//  SavedLocationsRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

final class SavedLocationsRepository: SavedLocationsRepositoryProtocol {

    // MARK: - Dependencies
    private let cache: LocationCacheProtocol

    // MARK: - Init
    init(cache: LocationCacheProtocol) {
        self.cache = cache
    }

    // MARK: - Fetch All
    func fetchAllCachedLocations() -> [LocationPoint] {
        return cache.getAll()
    }
}
