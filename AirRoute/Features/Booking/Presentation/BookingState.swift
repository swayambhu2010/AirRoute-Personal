//
//  BookingState.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

struct BookingState {
    
    // MARK: - Input
    var locationA: LocationPoint? = nil
    var locationB: LocationPoint? = nil
    
    // MARK: - Result
    var bookingResult: BookingResult? = nil
    
    // MARK: - Loading
    var isLoading: Bool = false
    
    // MARK: - Error
    var errorMessage: String? = nil
    
    // MARK: - Computed — Location Names
    var aLocationName: String {
        bookingResult?.locationA.displayName
        ?? locationA?.displayName
        ?? ""
    }
    
    var bLocationName: String {
        bookingResult?.locationB.displayName
        ?? locationB?.displayName
        ?? ""
    }
    
    // MARK: - Computed — AQI
    var aAQI: Int {
        bookingResult?.locationA.aqi
        ?? locationA?.aqi
        ?? 0
    }
    
    var bAQI: Int {
        bookingResult?.locationB.aqi
        ?? locationB?.aqi
        ?? 0
    }
    
    // MARK: - Computed — Nickname
    // From input LocationPoint
    // not in server response
    var aNickname: String? {
        locationA?.nickname
    }
    
    var bNickname: String? {
        locationB?.nickname
    }
    
    // MARK: - Price
    var formattedPrice: String {
        guard let result = bookingResult else {
            return CurrencyFormatter.format(0)
        }
        return CurrencyFormatter.format(result.price) 
    }
}
