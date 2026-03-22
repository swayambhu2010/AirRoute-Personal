//
//  MapState.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import CoreLocation
import SharedModels

struct MapState {

    // MARK: - Map Center
    // Current pin position
    // Changes as user drags map
    // nil until first GPS received
    var mapCenter: CLLocationCoordinate2D? = nil

    // MARK: - GPS Location
    // Real device GPS coordinate
    // Set ONCE when LocationManager publishes
    // Survives all resets — permanent anchor ✅
    // Used to return map home after booking
    var currentGPSLocation: CLLocationCoordinate2D? = nil

    // MARK: - Initial Location Flag
    // false → GPS not yet received → show loading
    // true  → real GPS received    → render map
    // Prevents map rendering at hardcoded coordinate
    var hasReceivedInitialLocation: Bool = false

    // MARK: - Drag State
    // true  = user finger on screen, map moving
    // false = map settled / idle
    // Drives PinOverlayView lift animation
    var isDragging: Bool = false

    // MARK: - Locations
    var locationA: LocationPoint? = nil
    var locationB: LocationPoint? = nil

    // MARK: - AQI
    // Displayed in top-right badge
    // Updates every time camera settles (debounced 0.5s)
    var currentAQI: Int = 0

    // MARK: - Button
    var buttonState: BookingButtonState = .setA

    // MARK: - Loading
    var isLoading: Bool = false

    // MARK: - Error
    var errorMessage: String? = nil

    // MARK: - Computed

    var buttonTitle: String {
        switch buttonState {
        case .setA: return "Set A"
        case .setB: return "Set B"
        case .book: return "Book"
        }
    }

    var aLabelText: String {
        locationA?.displayName ?? "A"
    }

    var bLabelText: String {
        locationB?.displayName ?? "B"
    }

    var isALabelEmpty: Bool { locationA == nil }
    var isBLabelEmpty: Bool { locationB == nil }

    // MARK: - Safe Map Center
    // NEVER returns nil
    // Priority: mapCenter → GPS → Seoul fallback
    // Used by MapRenderView — no force unwrap needed ✅
    var safeMapCenter: CLLocationCoordinate2D {
        mapCenter
            ?? currentGPSLocation
            ?? CLLocationCoordinate2D(
                latitude: 37.5642,
                longitude: 127.0016
            )
    }
}
