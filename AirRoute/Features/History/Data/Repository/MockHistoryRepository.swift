//
//  MockHistoryRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

final class MockHistoryRepository: HistoryRepositoryProtocol {
    
    func fetchHistory(
        year: Int,
        month: Int
    ) async throws -> [BookingResult] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        return MockData.bookingHistory  // Static mock data
    }
}
