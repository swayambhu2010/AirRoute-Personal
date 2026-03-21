//
//  CacheTTL.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 16/03/26.
//

import Foundation

// MARK: - CacheTTL
// Centralised TTL constants
// Easy to tune per data type
enum CacheTTL {

    // Address (name) — static data
    // A street name won't change in a session
    // Cache for 24 hours
    static let address: TimeInterval = 60 * 60 * 24

    // AQI — dynamic, changes hourly
    // Refresh every 30 minutes
    static let aqi: TimeInterval = 60 * 30
}
