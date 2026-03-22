//
//  MockSavedLocationsRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

final class MockSavedLocationsRepository: SavedLocationsRepositoryProtocol {

    // MARK: - In Memory Storage
    private var locations: [String: LocationPoint]

    // MARK: - Init
    init() {
        var initial: [String: LocationPoint] = [:]

        let mockLocations: [LocationPoint] = [
            LocationPoint(
                latitude: 37.5642,
                longitude: 127.0016,
                aqi: 30,
                name: "Gangnam-gu, Seoul",
                nickname: "Home"
            ),
            LocationPoint(
                latitude: 37.5700,
                longitude: 127.0200,
                aqi: 45,
                name: "Songpa-gu, Seoul",
                nickname: "Office"
            ),
            LocationPoint(
                latitude: 37.5800,
                longitude: 127.0100,
                aqi: 60,
                name: "Mapo-gu, Seoul",
                nickname: nil
            ),
            LocationPoint(
                latitude: 37.5500,
                longitude: 126.9900,
                aqi: 75,
                name: "Yongsan-gu, Seoul",
                nickname: nil
            )
        ]

        mockLocations.forEach { location in
            let key = CacheKeyGenerator.key(
                latitude: location.latitude,
                longitude: location.longitude
            )
            initial[key] = location
        }

        self.locations = initial
    }

    // MARK: - Fetch All
    func fetchAllCachedLocations() -> [LocationPoint] {
        return Array(locations.values)
    }
}
