//
//  BookingRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import SharedModels

final class BookingRepository: BookingRepositoryProtocol {

    // MARK: - Dependencies
    private let networkService: NetworkRequest

    // MARK: - Init
    init(networkService: NetworkRequest) {
        self.networkService = networkService
    }

    // MARK: - Screen 3
    // Called by BookRideUseCase
    func book(
        locationA: LocationPoint,
        locationB: LocationPoint
    ) async throws -> BookingResult {

        let requestDTO = BookingRequestDTO(
            a: locationA.toDTO(),
            b: locationB.toDTO()
        )

        let responseDTO: BookingResponseDTO = try await networkService.request(
            apiRequest: BookingEndpoint.book(
                request: requestDTO
            )
        )

        return responseDTO.toDomain()
    }
}
