//
//  BookingButtonState.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

/// Controls the V Button state on Screen 1
/// Set A → Set B → Book
enum BookingButtonState {
    case setA       // Initial state — nothing set
    case setB       // A is set — waiting for B
    case book       // Both A and B set — ready to book
    
    var title: String {
        switch self {
        case .setA:  return "Set A"
        case .setB:  return "Set B"
        case .book:  return "Book"
        }
    }
}
