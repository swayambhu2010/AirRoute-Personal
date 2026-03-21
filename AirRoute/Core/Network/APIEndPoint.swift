//
//  APIEndPoint.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

protocol APIEndPoint {
    var schema: String { get }
    var baseURL: String { get }
    var path: String { get }
    var queryParams: [URLQueryItem]? { get }
    var header: [String: String] { get }
    var method: HTTPMethod { get }
    // ← Now throws — encoding errors surface immediately
    func body() throws -> Data?
}

extension APIEndPoint {
    var schema: String { "https" }
    var queryParams: [URLQueryItem]? { nil }
    var header: [String: String] { [:] }
    // ← Default returns nil — endpoints with no body
    // don't need to implement this
    func body() throws -> Data? { nil }
}
