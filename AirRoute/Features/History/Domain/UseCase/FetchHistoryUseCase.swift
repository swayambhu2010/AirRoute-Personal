//
//  FetchHistoryUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - Protocol
protocol FetchHistoryUseCaseProtocol {
    func execute(
        year: Int,
        month: Int
    ) async throws -> [BookingResult]
}

// MARK: - Implementation
final class FetchHistoryUseCase: FetchHistoryUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: HistoryRepositoryProtocol

    // MARK: - Init
    init(repository: HistoryRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Fetches booking history for year + month
    /// Business Rules:
    /// 1. Month must be between 1 and 12
    /// 2. Year cannot be in the future
    /// Called when:
    /// Screen 4 appears or
    /// User changes month/year filter
    func execute(
        year: Int,
        month: Int
    ) async throws -> [BookingResult] {

        // Rule 1: Month must be 1-12
        guard (1...12).contains(month) else {
            throw HistoryError.invalidMonth
        }

        // Rule 2: Year cannot be future
        let currentYear = Calendar.current
            .component(.year, from: Date())

        guard year <= currentYear else {
            throw HistoryError.invalidYear
        }

        return try await repository.fetchHistory(
            year: year,
            month: month
        )
    }
}
