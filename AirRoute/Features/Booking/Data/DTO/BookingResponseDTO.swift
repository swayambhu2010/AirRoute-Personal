//
//  BookingResponseDTO.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

// MARK: - BookingResponseDTO
// Decodable — received from POST /books
// Server responds with:
// {
//   "id": "some-uuid-string",        ← optional: defensive coding
//   "a": { latitude, longitude, aqi, name },
//   "b": { latitude, longitude, aqi, name },
//   "price": 10000
// }

struct BookingResponseDTO: Decodable {
    let id: String?                  // optional — defensive, in case server omits it
    let a: LocationPointDTO
    let b: LocationPointDTO
    let price: Double

    // MARK: - To Domain
    func toDomain() -> BookingResult {
        return BookingResult(
            id: id ?? UUID().uuidString,    // fallback if server omits id
            locationA: a.toDomain(),
            locationB: b.toDomain(),
            price: price
        )
    }
}
