//
//  BookingError.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum BookingError: LocalizedError {

    case sameLocation

    var errorDescription: String? {
        switch self {
        case .sameLocation:
            return "Pick-up and drop-off cannot be the same location"
        }
    }
}
