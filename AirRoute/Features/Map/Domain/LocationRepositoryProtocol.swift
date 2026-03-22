//
//  LocationRepositoryProtocol.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import SharedModels

protocol LocationRepositoryProtocol {

    // MARK: - Screen 1 (Map)

    /// Full fetch — address + live AQI combined
    /// Address → cache first, API on miss
    /// AQI     → always live, never cached
    /// Called by FetchLocationInfoUseCase
    /// Trigger: App launch, V Button tap
    func fetchLocationInfo(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint

    /// Live AQI only — never cached
    /// Called by FetchAQIUseCase
    /// Trigger: Map drag stop, Screen resume
    func fetchLiveAQI(
        latitude: Double,
        longitude: Double
    ) async throws -> Int

    // MARK: - Screen 2 (Location Detail)

    /// Updates nickname in cache
    /// Called by UpdateNicknameUseCase
    func updateNickname(
        _ nickname: String,
        for location: LocationPoint
    ) throws

    /// Reads single location from cache
    /// Called by FetchCachedLocationUseCase
    func fetchCachedLocation(
        latitude: Double,
        longitude: Double
    ) -> LocationPoint?

    // MARK: - Screen 5 (Saved Locations)

    /// Returns all cached locations
    /// Called by FetchSavedLocationsUseCase
    func fetchAllCachedLocations() -> [LocationPoint]

    /// Removes location from cache
    /// Called by RemoveSavedLocationUseCase
    func removeCachedLocation(
        _ location: LocationPoint
    )
}
