//
//  LocationPoint.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import CoreLocation

import Foundation
import CoreLocation

struct LocationPoint: Equatable, Hashable {

    let latitude: Double
    let longitude: Double
    var aqi: Int
    var name: String
    var nickname: String?

    // MARK: - Computed Properties

    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        return name
    }

    // MARK: - Cache Key
    // Delegates to CacheKeyGenerator
    // Single source of rounding logic ✅
    // If rounding precision changes → fix in ONE place
    var cacheKey: String {
        CacheKeyGenerator.key(
            latitude: latitude,
            longitude: longitude
        )
    }

    // MARK: - DTO Conversion
    func toDTO() -> LocationPointRequestDTO {
        return LocationPointRequestDTO(
            latitude: latitude,
            longitude: longitude,
            aqi: aqi,
            name: name
        )
    }

    // MARK: - Coordinate
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

