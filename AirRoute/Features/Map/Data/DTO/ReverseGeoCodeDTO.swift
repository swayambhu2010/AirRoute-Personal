//
//  ReverseGeoCodeDTO.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

struct ReverseGeocodeDTO: Decodable {
    let latitude: Double
    let longitude: Double
    let localityInfo: LocalityInfo
    
    struct LocalityInfo: Decodable {
        let administrative: [AdministrativeItem]
    }
    
    struct AdministrativeItem: Decodable {
        let name: String
        let order: Int
    }
    
    // MARK: - Address Parsing
    // Take top 2 highest order items and concatenate
    // Reference: notion.so address-name-handling
    var parsedAddress: String {
        let topTwo = localityInfo.administrative
            .sorted { $0.order > $1.order }  // highest order first
            .prefix(2)
            .map { $0.name }
        return topTwo.joined(separator: " ")
    }
}
