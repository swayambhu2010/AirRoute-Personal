//
//  ReverseGeoCodeData+Mapping.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

extension ReverseGeocodeDTO {
    func toDomain() -> LocationPoint {
        LocationPoint(
            latitude: latitude,
            longitude: longitude,
            aqi: 0,           // AQI comes from separate API call
            name: parsedAddress,
            nickname: nil
        )
    }
}
