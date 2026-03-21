//
//  BookingRepositoryProtocol.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

protocol BookingRepositoryProtocol {

    // MARK: - Screen 3 (Booking)
    /// POST /books
    /// Sends A and B location data
    /// Returns booking result with price
    func book(
        locationA: LocationPoint,
        locationB: LocationPoint
    ) async throws -> BookingResult
}
