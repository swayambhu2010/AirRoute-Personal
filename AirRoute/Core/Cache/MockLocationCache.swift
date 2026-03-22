//
//  MockLocationCache.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

final class MockLocationCache: LocationCacheProtocol {

    private var storage: [String: LocationPoint] = [:]

    var setCallCount = 0
    var getCallCount = 0
    var getAddressOnlyCallCount = 0

    func set(_ location: LocationPoint, for key: String) {
        setCallCount += 1
        storage[key] = location
    }

    func get(for key: String) -> LocationPoint? {
        getCallCount += 1
        return storage[key]
    }

    // No TTL in mock — always returns if present
    func getAddressOnly(for key: String) -> LocationPoint? {
        getAddressOnlyCallCount += 1
        return storage[key]
    }

    func getAll() -> [LocationPoint] { Array(storage.values) }

    func remove(for key: String) {
        storage.removeValue(forKey: key)
    }

    func clearAll() { storage.removeAll() }

    func contains(for key: String) -> Bool { storage[key] != nil }
}
