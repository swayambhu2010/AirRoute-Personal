//
//  FetchLocationInfoUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

// MARK: - Protocol
protocol FetchLocationInfoUseCaseProtocol {
    func execute(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint
}

// MARK: - Implementation
final class FetchLocationInfoUseCase: FetchLocationInfoUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: LocationRepositoryProtocol

    // MARK: - Init
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Full fetch — address + AQI
    /// Called when:
    /// 1. App launches (initial position)
    /// 2. V Button tapped (Set A / Set B)
    func execute(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint {
        return try await repository.fetchLocationInfo(
            latitude: latitude,
            longitude: longitude
        )
    }
}
