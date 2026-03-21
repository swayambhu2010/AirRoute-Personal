//
//  FetchAQIUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - Protocol
protocol FetchAQIUseCaseProtocol {
    func execute(
        latitude: Double,
        longitude: Double
    ) async throws -> Int
}

// MARK: - Implementation
final class FetchAQIUseCase: FetchAQIUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: LocationRepositoryProtocol

    // MARK: - Init
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Live AQI fetch — never cached
    /// AQI is dynamic — changes over time
    /// Called when:
    /// 1. Map camera stops moving (debounced 0.5s)
    /// 2. Screen 1 resumes from Screen 2/3
    func execute(
        latitude: Double,
        longitude: Double
    ) async throws -> Int {
        return try await repository.fetchLiveAQI(
            latitude: latitude,
            longitude: longitude
        )
    }
}
