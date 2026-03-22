//
//  BookingAction.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

enum BookingAction {
    case onAppear           // ← lifecycle only, no side effects
    case startBooking       // ← explicit trigger for the actual booking
    case goToHistoryTapped
    case dismissTapped
    case bookingSucceeded(BookingResult)
    case bookingFailed(Error)
    case errorDismissed
}
