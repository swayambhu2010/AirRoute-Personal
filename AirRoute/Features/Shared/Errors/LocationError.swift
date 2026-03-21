//
//  LocationError.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum LocationError: LocalizedError {
    
    // MARK: - Cache Errors
    case locationNotFound       // location not in cache
    case nicknameTooLong        // nickname exceeds 20 chars
    
    // MARK: - Permission Errors
    case permissionDenied       // location permission denied
    
    // MARK: - API Errors
    case addressFetchFailed     // BigDataCloud API failed
    
}
