//
//  MapAction.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import CoreLocation

enum MapAction {

    // MARK: - Lifecycle
    case onAppear
    case onResume

    // MARK: - Map
    // Fired by GoogleMapView.idleAt
    // Pin settled — read center coordinate
    case mapCameraIdle(CLLocationCoordinate2D)

    // Fired by GoogleMapView.willMove(gesture: true)
    // Pin lifts while user drags
    case mapDragStarted

    // Fired once by LocationManager
    // Sets permanent GPS anchor ✅
    case initialLocationReceived(CLLocationCoordinate2D)

    // MARK: - V Button
    case vButtonTapped

    // MARK: - Labels
    // Empty label  → Screen 5
    // Filled label → Screen 2
    case labelTapped(LocationType)

    // MARK: - Internal Results
    case locationInfoFetched(LocationPoint)
    case aqiFetched(Int)
    case locationSet(LocationPoint, LocationType)
    case fetchFailed(Error)

    // MARK: - External Input

    // From Screen 5 — user picked saved location
    // Map moves to that location ✅
    case locationSelectedFromSaved(
        LocationPoint,
        LocationType
    )

    // From Screen 4 — user tapped history cell
    // Map moves to location A ✅
    case preloadFromHistory(
        a: LocationPoint,
        b: LocationPoint
    )

    // From Screen 2 — nickname saved
    // Label on Screen 1 updates immediately ✅
    case locationUpdated(LocationPoint, LocationType)

    // MARK: - Reset
    // Called when returning from Screen 3 with back
    // Map returns to current GPS location ✅
    case resetState

    // MARK: - Error
    case errorDismissed
}
