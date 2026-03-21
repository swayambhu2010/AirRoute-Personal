//
//  Double+Rounding.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

extension Double {
    
    /// Rounds to 3 decimal places
    /// Used for coordinate cache key generation
    var roundedToThreeDecimalPlaces: Double {
        (self * 1000).rounded() / 1000
    }
}
