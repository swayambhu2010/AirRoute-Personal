// Core/Network/APIRequest.swift

import Foundation

protocol BaseRequest {
    func createRequest(request: APIEndPoint) throws -> URLRequest?
}

struct APIRequest: BaseRequest {

    // ← Now throws to propagate body encoding errors
    func createRequest(request: APIEndPoint) throws -> URLRequest? {
        var component = URLComponents()
        component.scheme = request.schema
        component.host = request.baseURL
        component.path = request.path

        if let queryParams = request.queryParams,
           !queryParams.isEmpty {
            component.queryItems = queryParams
        }

        guard let url = component.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        if request.method != .get {
            urlRequest.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }

        request.header.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        // ← throws here — encoding error surfaces up the chain
        urlRequest.httpBody = try request.body()

        return urlRequest
    }
}
