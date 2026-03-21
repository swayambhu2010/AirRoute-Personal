//
//  HistoryEndPoints.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum HistoryEndpoint: APIEndPoint {

    case fetchHistory(year: Int, month: Int)

    var baseURL: String {
        // ← From Config.xcconfig via AppConfiguration
        AppConfiguration.shared.bookingBaseURL
    }

    var path: String {
        return "/books"
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParams: [URLQueryItem]? {
        switch self {
        case .fetchHistory(let year, let month):
            return [
                URLQueryItem(name: "year", value: "\(year)"),
                URLQueryItem(name: "month", value: "\(month)")
            ]
        }
    }
}
