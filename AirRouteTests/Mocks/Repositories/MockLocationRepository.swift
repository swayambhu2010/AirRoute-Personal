//
//  MockLocationRepository.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
@testable import AirRoute

final class MockLocationRepository: LocationRepositoryProtocol {

    // MARK: - fetchLocationInfo
    var fetchLocationInfoResult: Result<LocationPoint, Error> = .success(
        LocationPoint(
            latitude: 37.5642,
            longitude: 127.0016,
            aqi: 30,
            name: "Mock Location",
            nickname: nil
        )
    )
    var fetchLocationInfoCallCount = 0
    var fetchLocationInfoLastLatitude: Double?
    var fetchLocationInfoLastLongitude: Double?

    func fetchLocationInfo(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint {
        fetchLocationInfoCallCount += 1
        fetchLocationInfoLastLatitude = latitude
        fetchLocationInfoLastLongitude = longitude
        switch fetchLocationInfoResult {
        case .success(let point): return point
        case .failure(let error): throw error
        }
    }

    // MARK: - fetchLiveAQI
    var fetchLiveAQIResult: Result<Int, Error> = .success(42)
    var fetchLiveAQICallCount = 0
    var fetchLiveAQILastLatitude: Double?
    var fetchLiveAQILastLongitude: Double?

    func fetchLiveAQI(
        latitude: Double,
        longitude: Double
    ) async throws -> Int {
        fetchLiveAQICallCount += 1
        fetchLiveAQILastLatitude = latitude
        fetchLiveAQILastLongitude = longitude
        switch fetchLiveAQIResult {
        case .success(let aqi): return aqi
        case .failure(let error): throw error
        }
    }

    // MARK: - updateNickname
    var updateNicknameErrorToThrow: Error? = nil
    var updateNicknameCallCount = 0
    var updateNicknameLastNickname: String?
    var updateNicknameLastLocation: LocationPoint?

    func updateNickname(
        _ nickname: String,
        for location: LocationPoint
    ) throws {
        updateNicknameCallCount += 1
        updateNicknameLastNickname = nickname
        updateNicknameLastLocation = location
        if let error = updateNicknameErrorToThrow {
            throw error
        }
    }

    // MARK: - fetchCachedLocation
    var fetchCachedLocationResult: LocationPoint? = nil
    var fetchCachedLocationCallCount = 0
    var fetchCachedLocationLastLatitude: Double?
    var fetchCachedLocationLastLongitude: Double?

    func fetchCachedLocation(
        latitude: Double,
        longitude: Double
    ) -> LocationPoint? {
        fetchCachedLocationCallCount += 1
        fetchCachedLocationLastLatitude = latitude
        fetchCachedLocationLastLongitude = longitude
        return fetchCachedLocationResult
    }

    // MARK: - fetchAllCachedLocations
    var fetchAllCachedLocationsResult: [LocationPoint] = []
    var fetchAllCachedLocationsCallCount = 0

    func fetchAllCachedLocations() -> [LocationPoint] {
        fetchAllCachedLocationsCallCount += 1
        return fetchAllCachedLocationsResult
    }

    // MARK: - removeCachedLocation
    var removeCachedLocationCallCount = 0
    var removeCachedLocationLastLocation: LocationPoint?

    func removeCachedLocation(_ location: LocationPoint) {
        removeCachedLocationCallCount += 1
        removeCachedLocationLastLocation = location
    }
}
