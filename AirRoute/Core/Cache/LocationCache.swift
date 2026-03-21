//
//  LocationCache.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

final class LocationCache: LocationCacheProtocol {

    // MARK: - Configuration
    // Max 100 entries — enough for a full session
    // Prevents unbounded growth from map dragging
    private let maxSize: Int

    // MARK: - Storage
    private var storage: [String: CacheEntry<LocationPoint>] = [:]

    // MARK: - LRU Tracking
    // Ordered list of keys — most recently used at END
    // When evicting → remove from FRONT (least recently used)
    private var accessOrder: [String] = []

    // MARK: - Thread Safety
    private let queue = DispatchQueue(
        label: "com.airroute.locationcache",
        attributes: .concurrent
    )

    // MARK: - Init
    // maxSize injected — testable ✅
    init(maxSize: Int = 100) {
        self.maxSize = maxSize
    }

    // MARK: - Set
    func set(_ location: LocationPoint, for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }

            // Update existing entry
            if self.storage[key] != nil {
                self.storage[key] = CacheEntry(value: location)
                self.touchKey(key)
                return
            }

            // Evict LRU entry if at capacity
            if self.storage.count >= self.maxSize {
                self.evictLeastRecentlyUsed()
            }

            // Insert new entry
            self.storage[key] = CacheEntry(value: location)
            self.accessOrder.append(key)
        }
    }

    // MARK: - Get (AQI-aware)
    func get(for key: String) -> LocationPoint? {
        queue.sync {
            guard let entry = storage[key] else { return nil }
            guard !entry.isExpired(ttl: CacheTTL.aqi) else { return nil }
            touchKey(key)       // ← mark as recently used
            return entry.value
        }
    }

    // MARK: - Get Address Only
    func getAddressOnly(for key: String) -> LocationPoint? {
        queue.sync {
            guard let entry = storage[key] else { return nil }
            guard !entry.isExpired(ttl: CacheTTL.address) else { return nil }
            touchKey(key)       // ← mark as recently used
            return entry.value
        }
    }

    // MARK: - Get All
    func getAll() -> [LocationPoint] {
        queue.sync {
            storage.values
                .filter { !$0.isExpired(ttl: CacheTTL.aqi) }
                .map { $0.value }
        }
    }

    // MARK: - Remove
    func remove(for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            self.storage.removeValue(forKey: key)
            self.accessOrder.removeAll { $0 == key }
        }
    }

    // MARK: - Clear All
    func clearAll() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            self.storage.removeAll()
            self.accessOrder.removeAll()
        }
    }

    // MARK: - Contains
    func contains(for key: String) -> Bool {
        queue.sync {
            guard let entry = storage[key] else { return false }
            return !entry.isExpired(ttl: CacheTTL.aqi)
        }
    }

    // MARK: - Private Helpers

    // Move key to end of accessOrder = most recently used
    // Must be called inside queue context
    private func touchKey(_ key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }

    // Remove front of accessOrder = least recently used
    // Must be called inside queue context
    private func evictLeastRecentlyUsed() {
        guard let lruKey = accessOrder.first else { return }
        storage.removeValue(forKey: lruKey)
        accessOrder.removeFirst()
    }
}
