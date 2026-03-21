//
//  AppConfiguration.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - Protocol
protocol AppConfigurationProtocol {

    // MARK: - Base URLs
    var bigDataCloudBaseURL: String { get }
    var aqiBaseURL: String { get }
    var bookingBaseURL: String { get }

    // MARK: - API Keys
    var aqiAPIKey: String { get }

    // MARK: - Google Maps
    var googleMapsAPIKey: String { get }
}

// MARK: - Implementation
final class AppConfiguration: AppConfigurationProtocol {
    
    // MARK: - Shared
    static let shared = AppConfiguration()
    private init() {}

    // MARK: - Base URLs
    var bigDataCloudBaseURL: String {
        value(for: "BIG_DATA_CLOUD_BASE_URL")
    }

    var aqiBaseURL: String {
        value(for: "AQI_BASE_URL")
    }

    var bookingBaseURL: String {
        value(for: "BOOKING_BASE_URL")
    }

    var aqiAPIKey: String {
        value(for: "AQI_API_KEY")
    }

    // MARK: - Google Maps
    var googleMapsAPIKey: String {
        value(for: "GOOGLE_MAPS_API_KEY")
    }

    // MARK: - Private
    private func value(for key: String) -> String {
        guard
            let value = Bundle.main
                .object(forInfoDictionaryKey: key) as? String,
            !value.isEmpty
        else {
            fatalError(
                "⚠️ Missing config key: \(key) " +
                "— add it to Config.xcconfig"
            )
        }
        return value
    }
}
