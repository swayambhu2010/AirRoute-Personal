//
//  MockData.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import SharedModels

enum MockData {
    
    static let bookingHistory: [BookingResult] = [
        BookingResult(
            id: UUID().uuidString,
            locationA: LocationPoint(
                latitude: 36.564,
                longitude: 127.001,
                aqi: 30,
                name: "Seoul A Location",
                nickname: nil
            ),
            locationB: LocationPoint(
                latitude: 36.567,
                longitude: 127.000,
                aqi: 40,
                name: "Seoul B Location",
                nickname: nil
            ),
            price: 10000
        ),
        BookingResult(
            id: UUID().uuidString, 
            locationA: LocationPoint(
                latitude: 36.577,
                longitude: 127.033,
                aqi: 50,
                name: "Seoul C Location",
                nickname: nil
            ),
            locationB: LocationPoint(
                latitude: 36.567,
                longitude: 127.000,
                aqi: 60,
                name: "Seoul D Location",
                nickname: nil
            ),
            price: 20000
        )
    ]
}
