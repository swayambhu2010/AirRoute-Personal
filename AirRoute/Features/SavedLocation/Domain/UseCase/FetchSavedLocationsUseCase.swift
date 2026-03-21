//
//  FetchSavedLocationsUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - Protocol
protocol FetchSavedLocationsUseCaseProtocol {
    func execute() -> [LocationPoint]
}

// MARK: - Implementation
final class FetchSavedLocationsUseCase: FetchSavedLocationsUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: SavedLocationsRepositoryProtocol  // ✅

    // MARK: - Init
    init(repository: SavedLocationsRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Returns all cached locations
    /// Business Rules:
    /// 1. Nicknamed locations appear first
    /// 2. Within same group sort alphabetically
    ///    by displayName
    /// 3. Empty list is valid — show empty state
    func execute() -> [LocationPoint] {

        let locations = repository.fetchAllCachedLocations()

        guard !locations.isEmpty else { return [] }

        return locations.sorted {
            switch ($0.nickname, $1.nickname) {
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            default:
                return $0.displayName < $1.displayName
            }
        }
    }
}
