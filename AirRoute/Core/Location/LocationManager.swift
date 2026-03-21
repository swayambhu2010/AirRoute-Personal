//
//  LocationManager.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject,
                             ObservableObject,
                             LocationManagerProtocol,
                             CLLocationManagerDelegate {
    
    // MARK: - Published
    // @Published so MapScreen can observe via .onReceive
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    
    // MARK: - LocationManagerProtocol
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Private
    private let manager = CLLocationManager()
    
    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
        
        requestPermission()
    }
    
    // MARK: - LocationManagerProtocol
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first
        else { return }
        
        // Only publish ONCE
        // Screen 1 uses this to set initial map center
        currentLocation = location.coordinate
        stopUpdatingLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted → start fetching
            startUpdatingLocation()
            
        case .denied, .restricted:
            // Permission denied → fallback to Seoul
            currentLocation = CLLocationCoordinate2D(
                latitude: 37.5642,
                longitude: 127.0016
            )
            
            
        case .notDetermined:
            // Waiting for user response
            break
            
        @unknown default:
            break
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Fallback to Seoul city center
        currentLocation = CLLocationCoordinate2D(
            latitude: 37.5642,
            longitude: 127.0016
        )
    }
}
