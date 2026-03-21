//
//  MockFetchAQIUseCase.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
@testable import AirRoute

final class MockFetchAQIUseCase: FetchAQIUseCaseProtocol {

    // MARK: - Control
    var result: Result<Int, Error> = .success(42)

    // MARK: - Tracking
    var callCount = 0
    var lastLatitude: Double!
    var lastLongitude: Double!

    // MARK: - Execute
    func execute(
        latitude: Double,
        longitude: Double
    ) async throws -> Int {
        callCount += 1
        lastLatitude = latitude
        lastLongitude = longitude
        switch result {
        case .success(let aqi): return aqi
        case .failure(let error): throw error
        }
    }
}
