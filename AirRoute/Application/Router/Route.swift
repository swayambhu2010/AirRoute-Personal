//
//  Route.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

enum Route: Hashable {
    case locationDetail(location: LocationPoint, type: LocationType)
    case bookingConfirmation(a: LocationPoint, b: LocationPoint)
    case history
    case savedLocations(selectingFor: LocationType)
}
