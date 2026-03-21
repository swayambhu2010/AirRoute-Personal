//
//  ResponseDecoder.swift
//  System Design
//
//  Created by Swayambhu BANERJEE on 21/01/26.
//

import Foundation

protocol ResponseDecoder {
    func decodeResponse<T: Decodable>(type: T.Type, data: Data) throws -> T
}

final class ResponseObject: ResponseDecoder {
    
    private let decoder: JSONDecoder  // ← instance variable
    
     init() {
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func decodeResponse<T>(type: T.Type, data: Data) throws -> T where T : Decodable {
        try decoder.decode(type, from: data)
    }
}
