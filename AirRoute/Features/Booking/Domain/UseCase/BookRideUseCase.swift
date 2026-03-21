//
//  BookRideUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - Protocol
protocol BookRideUseCaseProtocol {
    func execute(
        a: LocationPoint,
        b: LocationPoint
    ) async throws -> BookingResult
}

// MARK: - Implementation
final class BookRideUseCase: BookRideUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: BookingRepositoryProtocol

    // MARK: - Init
    init(repository: BookingRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Books a ride from A → B
    /// Business Rules:
    /// 1. A and B cannot be same location
    /// 2. Both A and B must be valid locations
    /// Called when:
    /// User taps Book button on Screen 3
    func execute(
        a: LocationPoint,
        b: LocationPoint
    ) async throws -> BookingResult {

        // Rule 1: A and B cannot be same location
        let keyA = CacheKeyGenerator.key(
            latitude: a.latitude,
            longitude: a.longitude
        )
        let keyB = CacheKeyGenerator.key(
            latitude: b.latitude,
            longitude: b.longitude
        )

        guard keyA != keyB else {
            throw BookingError.sameLocation
        }

        return try await repository.book(
            locationA: a,
            locationB: b
        )
    }
}
