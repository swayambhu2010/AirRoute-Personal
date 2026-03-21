//
//  CacheKeyGenerator.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

enum CacheKeyGenerator {

    /// Generates a cache key from coordinates
    /// rounded to 3 decimal places
    ///
    /// Rule:
    /// If lat + lon match up to 3 decimal places
    /// → treat as same location
    ///
    /// Example:
    /// lat: 37.5642, lon: 127.0016 → "37.564_127.002"
    /// lat: 37.5645, lon: 127.0018 → "37.564_127.002" ← SAME KEY
    /// lat: 37.5655, lon: 127.2321 → "37.566_127.232" ← DIFFERENT
    static func key(
        latitude: Double,
        longitude: Double
    ) -> String {
        let roundedLat = latitude.roundedToThreeDecimalPlaces
        let roundedLon = longitude.roundedToThreeDecimalPlaces
        return "\(roundedLat)_\(roundedLon)"
    }
}
