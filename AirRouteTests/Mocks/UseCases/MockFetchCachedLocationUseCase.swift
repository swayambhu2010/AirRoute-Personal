//
//  MockFetchCachedLocationUseCase.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
@testable import AirRoute

final class MockFetchCachedLocationUseCase: FetchCachedLocationUseCaseProtocol {

    // MARK: - Control
    // nil = cache miss
    // non-nil = cache hit
    var result: LocationPoint? = nil

    // MARK: - Tracking
    var callCount = 0
    var lastLatitude: Double?
    var lastLongitude: Double?

    // MARK: - Execute
    // Synchronous — cache is always instant ✅
    func execute(
        latitude: Double,
        longitude: Double
    ) -> LocationPoint? {
        callCount += 1
        lastLatitude = latitude
        lastLongitude = longitude
        return result
    }
}
