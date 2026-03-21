//
//  URLSession.swift
//  System Design
//
//  Created by Swayambhu BANERJEE on 21/01/26.
//

import Foundation
import Alamofire

protocol SessionManager {
    func execute(url: URLRequest) async throws -> Data
}

import Foundation
import Alamofire

// MARK: - Timeout Configuration
// Different endpoints need different timeouts
// Booking = fast (user is waiting on a spinner)
// History = can be slightly more lenient

struct NetworkTimeoutConfig {
    let requestTimeout: TimeInterval
    let resourceTimeout: TimeInterval

    // MARK: - Presets

    // Default for most API calls
    // 15s is standard for mobile apps
    static let standard = NetworkTimeoutConfig(
        requestTimeout: 15,
        resourceTimeout: 30
    )
}

// MARK: - AlamofireSessionManager
final class AlamofireSessionManager: SessionManager {

    // MARK: - Session
    private let session: Session

    // MARK: - Init
    // timeoutConfig injected — testable + flexible
    init(
        timeoutConfig: NetworkTimeoutConfig = .standard
    ) {
        // URLSessionConfiguration with custom timeouts
        let configuration = URLSessionConfiguration.default

        // Time allowed to connect to server
        configuration.timeoutIntervalForRequest =
            timeoutConfig.requestTimeout

        // Time allowed for entire resource load
        configuration.timeoutIntervalForResource =
            timeoutConfig.resourceTimeout

        // Additional sensible mobile defaults
        // Don't use cellular data if WiFi available
        configuration.allowsCellularAccess = true

        // Wait for connectivity before failing
        // Instead of immediately returning error
        configuration.waitsForConnectivity = true

        self.session = Session(configuration: configuration)
    }

    // MARK: - Execute
    func execute(url: URLRequest) async throws -> Data {
        let afResponse = await session
            .request(url)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response

        switch afResponse.result {
        case .success(let data):
            return data

        case .failure(let afError):
            throw mapError(afError, response: afResponse.response)
        }
    }

    // MARK: - Private
    // Maps AFError → NetworkError
    private func mapError(
        _ error: AFError,
        response: HTTPURLResponse?
    ) -> NetworkError {

        if let statusCode = response?.statusCode,
           !(200..<300).contains(statusCode) {
            return .httpError(statusCode: statusCode)
        }

        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                break
            }
        }

        return .invalidResponse
    }
}
