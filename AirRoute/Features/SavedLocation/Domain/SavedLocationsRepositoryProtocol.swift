//
//  SavedLocationsRepositoryProtocol.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

protocol SavedLocationsRepositoryProtocol {

    /// Returns all locations stored in cache
    /// These are locations user has set as A or B
    /// on Screen 1
    func fetchAllCachedLocations() -> [LocationPoint]
}
