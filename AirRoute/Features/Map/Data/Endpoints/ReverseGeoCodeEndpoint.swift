//
//  ReverseGeoCodeEndpoint.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum ReverseGeocodeEndpoint: APIEndPoint {

    case reverseGeocode(latitude: Double, longitude: Double)

    var baseURL: String {
        // ← From Config.xcconfig via AppConfiguration
        AppConfiguration.shared.bigDataCloudBaseURL
    }

    var path: String {
        return "/data/reverse-geocode-client"
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParams: [URLQueryItem]? {
        switch self {
        case .reverseGeocode(let latitude, let longitude):
            return [
                URLQueryItem(
                    name: "latitude",
                    value: "\(latitude)"
                ),
                URLQueryItem(
                    name: "longitude",
                    value: "\(longitude)"
                ),
                URLQueryItem(
                    name: "localityLanguage",
                    value: "en"
                )
            ]
        }
    }
}
