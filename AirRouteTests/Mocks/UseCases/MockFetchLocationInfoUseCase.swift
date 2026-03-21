//
//  MockFetchLocationInfoUseCase.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
@testable import AirRoute

final class MockFetchLocationInfoUseCase: FetchLocationInfoUseCaseProtocol {

    // MARK: - Control
    var result: Result<LocationPoint, Error> = .success(
        LocationPoint(
            latitude: 37.5642,
            longitude: 127.0016,
            aqi: 30,
            name: "Mock Location",
            nickname: nil
        )
    )

    // MARK: - Tracking
    var callCount = 0
    var lastLatitude: Double?
    var lastLongitude: Double?

    // MARK: - Execute
    func execute(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint {
        callCount += 1
        lastLatitude = latitude
        lastLongitude = longitude
        switch result {
        case .success(let point): return point
        case .failure(let error): throw error
        }
    }
}
