//
//  CacheEntry.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 16/03/26.
//

import Foundation

// MARK: - CacheEntry
// Wraps any cached value with a timestamp
// Generic — works for LocationPoint today
// works for anything tomorrow
struct CacheEntry<T> {

    // MARK: - Properties
    let value: T
    let cachedAt: Date

    // MARK: - Init
    init(value: T, cachedAt: Date = Date()) {
        self.value = value
        self.cachedAt = cachedAt
    }

    // MARK: - Expiry Check
    // Returns true if entry is older than TTL
    func isExpired(ttl: TimeInterval) -> Bool {
        Date().timeIntervalSince(cachedAt) > ttl
    }
}
