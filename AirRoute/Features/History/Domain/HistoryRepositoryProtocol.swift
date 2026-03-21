//
//  HistoryRepositoryProtocol.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

protocol HistoryRepositoryProtocol {

    // MARK: - Screen 4 (History)
    /// GET /books?year=2020&month=11
    func fetchHistory(
        year: Int,
        month: Int
    ) async throws -> [BookingResult]
}
