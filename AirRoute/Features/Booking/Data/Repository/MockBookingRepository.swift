//
//  MockBookingRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

final class MockBookingRepository: BookingRepositoryProtocol {
    
    func book(
        locationA a: LocationPoint,
        locationB b: LocationPoint
    ) async throws -> BookingResult {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)
        return BookingResult(
            id: UUID().uuidString, 
            locationA: a,
            locationB: b,
            price: 10000.0      // Mock price
        )
    }
}
