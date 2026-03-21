//
//  GoogleMapView.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI
import GoogleMaps

// MARK: - GoogleMapView
// UIViewRepresentable bridge
// Wraps GMSMapView for SwiftUI
//
// Pin behaviour:
// ① Pin FIXED at screen center — never moves
// ② Map moves UNDER the pin
// ③ Camera idle → center coordinate → AQI update
// ④ Programmatic camera move ONLY for:
//    - Initial GPS arrival
//    - History preload
//    - Saved location selected
//    - Reset to GPS

struct GoogleMapView: UIViewRepresentable {

    // MARK: - Properties
    let initialCoordinate: CLLocationCoordinate2D
    let zoomLevel: Float
    let onCameraIdle: (CLLocationCoordinate2D) -> Void
    let onDragStarted: () -> Void

    // MARK: - makeUIView
    // Called ONCE on first render
    func makeUIView(context: Context) -> GMSMapView {

        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(
            latitude: initialCoordinate.latitude,
            longitude: initialCoordinate.longitude,
            zoom: zoomLevel
        )

        let mapView = GMSMapView(options: options)

        // Fill parent — without this map is 0×0
        mapView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        // MARK: Settings
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        // Disable rotation — north always up
        // Standard for cab apps ✅
        mapView.settings.rotateGestures = false

        mapView.delegate = context.coordinator

        return mapView
    }

    // MARK: - updateUIView
    // Called on every SwiftUI state change
    //
    // Move camera ONLY when:
    // - Coordinate meaningfully changed AND
    // - User is NOT actively dragging
    //
    // This handles:
    // ① Initial GPS arrival
    // ② History preload → move to location A
    // ③ Saved location picked → move to it
    // ④ Reset → return to GPS
    func updateUIView(
        _ mapView: GMSMapView,
        context: Context
    ) {
        let current = mapView.camera.target
        let new = initialCoordinate

        // Skip if no meaningful change
        // Prevents camera fighting @Published noise
        guard !current.isApproximatelyEqual(to: new) else {
            return
        }

        // Skip if user is actively dragging
        // Their gesture always takes priority ✅
        guard !context.coordinator.isDragging else {
            return
        }

        // Smoothly animate to new coordinate
        let camera = GMSCameraPosition(
            latitude: new.latitude,
            longitude: new.longitude,
            zoom: zoomLevel
        )
        mapView.animate(to: camera)
    }

    // MARK: - makeCoordinator
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(
            onCameraIdle: onCameraIdle,
            onDragStarted: onDragStarted
        )
    }
}

// MARK: - MapViewCoordinator
// Bridges GMSMapViewDelegate → SwiftUI closures
// Tracks drag state to prevent camera conflicts

final class MapViewCoordinator: NSObject, GMSMapViewDelegate {

    // MARK: - Properties
    private let onCameraIdle: (CLLocationCoordinate2D) -> Void
    private let onDragStarted: () -> Void

    // MARK: - Drag State
    // true  → user finger on screen
    // false → map settled
    private(set) var isDragging: Bool = false

    // MARK: - Init
    init(
        onCameraIdle: @escaping (CLLocationCoordinate2D) -> Void,
        onDragStarted: @escaping () -> Void
    ) {
        self.onCameraIdle = onCameraIdle
        self.onDragStarted = onDragStarted
    }

    // MARK: - GMSMapViewDelegate

    // MARK: willMove
    // gesture = true  → user drag
    // gesture = false → programmatic (animate(to:))
    func mapView(
        _ mapView: GMSMapView,
        willMove gesture: Bool
    ) {
        guard gesture else { return }
        // User started dragging
        isDragging = true
        // Notify ViewModel → pin lifts ✅
        onDragStarted()
    }

    // MARK: idleAt — CORE BEHAVIOUR
    // Camera fully stopped
    // Pin has "landed" at map center
    //
    // Flow after this fires:
    // → onCameraIdle(position.target)
    // → MapViewModel.send(.mapCameraIdle)
    // → state.isDragging = false → pin settles ✅
    // → state.mapCenter = coordinate
    // → debouncer 0.5s → fetchAQI ✅
    // → AQI badge updates ✅
    func mapView(
        _ mapView: GMSMapView,
        idleAt position: GMSCameraPosition
    ) {
        isDragging = false
        // position.target = exact map center
        // = where pin tip points ✅
        onCameraIdle(position.target)
    }
}

// MARK: - CLLocationCoordinate2D Helper
extension CLLocationCoordinate2D {

    // 4 decimal places ≈ 11 metres precision
    // Prevents redundant camera animations
    // from floating point noise in @Published
    func isApproximatelyEqual(
        to other: CLLocationCoordinate2D,
        precision: Double = 0.0001
    ) -> Bool {
        abs(latitude - other.latitude) < precision &&
        abs(longitude - other.longitude) < precision
    }
}
