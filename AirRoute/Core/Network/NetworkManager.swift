//
//  NetworkManager.swift
//  System Design
//
//  Created by Swayambhu BANERJEE on 21/01/26.
//

import Foundation

 protocol NetworkRequest {
    func request<T:Decodable>(apiRequest: APIEndPoint) async throws -> T
}

final class NetworkManager: NetworkRequest {

    private var requestBuilder: BaseRequest
    private var sessionManager: SessionManager
    private var decoder: ResponseDecoder

    init(
        requestBuilder: BaseRequest,
        sessionManager: SessionManager,
        decoder: ResponseDecoder
    ) {
        self.requestBuilder = requestBuilder
        self.sessionManager = sessionManager
        self.decoder = decoder
    }

    convenience init(sessionManager: SessionManager) {
        self.init(
            requestBuilder: APIRequest(),
            sessionManager: sessionManager,
            decoder: ResponseObject()
        )
    }

    func request<T: Decodable>(
        apiRequest: APIEndPoint
    ) async throws -> T {

        // ← createRequest now throws
        // Encoding failure mapped to NetworkError.encodingError
        // Surfaces to ViewModel as a real typed error
        guard let urlRequest = try requestBuilder
            .createRequest(request: apiRequest)
        else {
            throw NetworkError.invalidURL
        }

        let data = try await sessionManager.execute(url: urlRequest)
        return try decoder.decodeResponse(type: T.self, data: data)
    }
}
