//
//  AQIResponseDTO.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

struct AQIResponseDTO: Decodable {
    let status: String
    let data: AQIData
    
    struct AQIData: Decodable {
        let aqi: Int
    }
    
    // MARK: - Validation
    var isValid: Bool {
        status == "ok"
    }
}
