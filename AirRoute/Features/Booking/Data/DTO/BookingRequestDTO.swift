//
//  BookingRequestDTO.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import SharedModels

// MARK: - BookingRequestDTO
// Encodable — sent as POST body to /books
// Server expects:
// {
//   "a": { latitude, longitude, aqi, name },
//   "b": { latitude, longitude, aqi, name }
// }

struct BookingRequestDTO: Encodable {
    let a: LocationPointRequestDTO
    let b: LocationPointRequestDTO
}
