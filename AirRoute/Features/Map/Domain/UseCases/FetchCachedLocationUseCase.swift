//
//  FetchCachedLocationUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

// MARK: - Protocol
protocol FetchCachedLocationUseCaseProtocol {
    func execute(
        latitude: Double,
        longitude: Double
    ) -> LocationPoint?
}

// MARK: - Implementation
final class FetchCachedLocationUseCase: FetchCachedLocationUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: LocationRepositoryProtocol

    // MARK: - Init
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Reads a single location from cache
    /// No API call — cache only
    /// Called when:
    /// Screen 2 appears — load existing
    /// address + nickname for display
    func execute(
        latitude: Double,
        longitude: Double
    ) -> LocationPoint? {
        return repository.fetchCachedLocation(
            latitude: latitude,
            longitude: longitude
        )
    }
}
