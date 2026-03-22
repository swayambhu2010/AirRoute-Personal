//
//  SavedLocationAction.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

enum SavedLocationsAction {
    case onAppear
    case locationTapped(LocationPoint)
    case dismissTapped
}
