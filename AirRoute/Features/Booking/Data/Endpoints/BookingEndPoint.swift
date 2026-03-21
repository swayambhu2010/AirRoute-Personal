//
//  BookingEndPoint.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

import Foundation

enum BookingEndpoint: APIEndPoint {

    case book(request: BookingRequestDTO)

    var baseURL: String {
        AppConfiguration.shared.bookingBaseURL
    }

    var path: String { "/books" }

    var method: HTTPMethod { .post }

    // Encoding failure is now a real error
    // Surfaces all the way to the ViewModel
    // User sees meaningful error message
    func body() throws -> Data? {
        switch self {
        case .book(let request):
            return try JSONEncoder().encode(request)
        }
    }
}
