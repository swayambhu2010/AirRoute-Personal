//
//  LocationPointDTO.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 16/03/26.


import Foundation

// MARK: - LocationPointDTO
// Decodable — used when RECEIVING location from server
// Shared across BookingResponseDTO + HistoryResponseDTO

struct LocationPointDTO: Decodable {
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let name: String

    // MARK: - To Domain
    func toDomain() -> LocationPoint {
        return LocationPoint(
            latitude: latitude,
            longitude: longitude,
            aqi: aqi,
            name: name,
            nickname: nil     // nickname is LOCAL only — never from server
        )
    }
}

// MARK: - LocationPointRequestDTO
// Encodable — used when SENDING location to server
// Shared across BookingRequestDTO

struct LocationPointRequestDTO: Encodable {
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let name: String
}
