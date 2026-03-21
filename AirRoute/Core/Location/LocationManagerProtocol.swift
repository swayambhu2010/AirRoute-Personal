//
//  LocationManagerProtocol.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    
    /// Current location coordinates
    /// nil until permission granted and location fetched
    var currentLocation: CLLocationCoordinate2D? { get }
    
    /// Current authorization status
    var authorizationStatus: CLAuthorizationStatus { get }
    
    /// Request location permission
    /// Called once on first app launch
    func requestPermission()
    
    /// Start updating location
    func startUpdatingLocation()
    
    /// Stop updating location
    func stopUpdatingLocation()
}
