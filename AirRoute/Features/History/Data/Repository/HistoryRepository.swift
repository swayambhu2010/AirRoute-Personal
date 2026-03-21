//
//  HistoryRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

final class HistoryRepository: HistoryRepositoryProtocol {

    // MARK: - Dependencies
    private let networkService: NetworkRequest

    // MARK: - Init
    init(networkService: NetworkRequest) {
        self.networkService = networkService
    }

    // MARK: - Screen 4
    // Called by FetchHistoryUseCase
    func fetchHistory(
        year: Int,
        month: Int
    ) async throws -> [BookingResult] {

        let responseDTO: HistoryResponseDTO = try await networkService.request(
            apiRequest: HistoryEndpoint.fetchHistory(
                year: year,
                month: month
            )
        )

        return responseDTO.map { $0.toDomain() }
    }
}
