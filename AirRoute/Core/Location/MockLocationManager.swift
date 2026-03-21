//
//  MockLocationManager.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import CoreLocation
import Combine

final class MockLocationManager: LocationManagerProtocol, ObservableObject {

    // MARK: - LocationManagerProtocol
    var currentLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(
        latitude: 37.5642,
        longitude: 127.0016
    )

    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse

    func requestPermission() {}
    func startUpdatingLocation() {}
    func stopUpdatingLocation() {}
}
