//
//  AQIEndPoint.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum AQIEndpoint: APIEndPoint {

    case fetchAQI(latitude: Double, longitude: Double)

    var baseURL: String {
        // ← From Config.xcconfig via AppConfiguration
        AppConfiguration.shared.aqiBaseURL
    }

    var path: String {
        switch self {
        case .fetchAQI(let latitude, let longitude):
            return "/feed/geo:\(latitude);\(longitude)/"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParams: [URLQueryItem]? {
        return [
            URLQueryItem(
                name: "token",
                // ← From Config.xcconfig via AppConfiguration
                value: AppConfiguration.shared.aqiAPIKey
            )
        ]
    }
}
