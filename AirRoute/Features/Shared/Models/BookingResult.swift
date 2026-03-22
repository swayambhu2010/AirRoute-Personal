//
//  BookingResult.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

struct BookingResult: Identifiable, Equatable {

    // MARK: - Properties
    let id: String
    let locationA: LocationPoint
    let locationB: LocationPoint
    let price: Double

    // Device locale handled automatically ✅
    var formattedPrice: String {
        CurrencyFormatter.format(price)
    }
}
