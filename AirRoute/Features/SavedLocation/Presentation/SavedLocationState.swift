//
//  SavedLocationsState.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

struct SavedLocationsState {

    // MARK: - Data
    var locations: [LocationPoint] = []

    // MARK: - Context
    var selectingFor: LocationType = .locationA

    // MARK: - Computed
    var isEmpty: Bool {
        locations.isEmpty
    }

    // MARK: - Paired Groups
    // Locations grouped into pairs of 2
    // [ [A, B], [C, D], [E, F] ]
    // Last group may have 1 item if odd count
    var pairedGroups: [[LocationPoint]] {
        stride(from: 0, to: locations.count, by: 2).map {
            Array(locations[$0..<min($0 + 2, locations.count)])
        }
    }

    var title: String {
        switch selectingFor {
        case .locationA: return "Select Location A"
        case .locationB: return "Select Location B"
        }
    }
}
