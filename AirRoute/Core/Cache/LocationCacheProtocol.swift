//
//  LocationCache.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import SharedModels

protocol LocationCacheProtocol {

    /// Store a location point against its cache key
    func set(_ location: LocationPoint, for key: String)

    /// Retrieve location if it exists AND is not expired
    /// Returns nil if not found OR if AQI is stale
    func get(for key: String) -> LocationPoint?

    /// Retrieve location regardless of AQI expiry
    /// Used when we only need address (name) — not AQI
    func getAddressOnly(for key: String) -> LocationPoint?

    /// Retrieve ALL cached locations
    func getAll() -> [LocationPoint]

    /// Remove a specific cached location
    func remove(for key: String)

    /// Clear entire cache
    func clearAll()

    /// Check if a non-expired location exists
    func contains(for key: String) -> Bool
}
